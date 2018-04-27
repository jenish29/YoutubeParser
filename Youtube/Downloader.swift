//
//  Downloader.swift
//  Downloader
//
//  Created by Jenish on 8/11/17.
//  Copyright © 2017 Jenish. All rights reserved.
//

import Foundation

protocol DownloaderDelegate : class {
    func urlSession(didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    func resume(data : Data?, has403: Bool)
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    func completeWitherror(error: Error?)
}
class Downloader : NSObject, URLSessionDownloadDelegate {

    var backgroundIdentifier : String!

    //download delegate
    var delegate : DownloaderDelegate?
    //download session
    var session : URLSession!

    //download task
    var task : URLSessionDownloadTask?
    var resumeData : Data?

    //function to download
    func download(url : URL?) {
        if resumeData == nil && task == nil && session != nil{
            task?.suspend()
            task = session.downloadTask(with: url!)
            task?.resume()
            globalTask = task
        }
        else if resumeData != nil && task == nil && session != nil{
            task = session.downloadTask(withResumeData: resumeData!)
            task?.resume()
            globalTask = task
        }

    }

    func makeSession () {
        let config = URLSessionConfiguration.background(withIdentifier: backgroundIdentifier)
        session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        delegate?.urlSession(didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        delegate?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)

    }

    //this function will be called when there is a resume data to be downloaded
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            if error != nil {
                //downcasting err or nserror so we can use userinfo
                let err = error as NSError!

                if (err?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? NSNumber)?.intValue == NSURLErrorCancelledReasonUserForceQuitApplication || (err?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? NSNumber)?.intValue == NSURLErrorCancelledReasonBackgroundUpdatesDisabled {
                    //this is to resume data if possible
                    if let url = err?.userInfo[NSURLErrorFailingURLStringErrorKey] as? String {
                        //checking if the url is still valid or not
                        let haserror = Has403()
                        haserror.parse(urlString: url, completionHandler: { (has) in
                            if !has {
                                //getting resume data
                                if let data = err?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
                                    if self.isValidResumeData(data){
                                        self.resumeData = data
                                    }
                                    self.delegate?.resume(data: data, has403: !self.isValidResumeData(data))
                                }
                                else{
                                    //no resume data exits
                                    self.delegate?.resume(data: nil, has403: true)
                                }
                            }
                            else{
                                //resume url doesnt exits
                                self.delegate?.resume(data: nil, has403: true)
                            }
                        })
                    }
                    else {
                        self.delegate?.resume(data: nil, has403: true)
                    }
                }else{
                        self.delegate?.resume(data: nil, has403: true)
                }
            }

        }
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
      //  print(error)
    }

    fileprivate func isValidResumeData(_ resumeData: Data?) -> Bool {

        guard resumeData != nil || (resumeData?.count)! > 0 else {
            return false
        }

        do {
            var resumeDictionary : AnyObject!
            resumeDictionary = try PropertyListSerialization.propertyList(from: resumeData!, options: PropertyListSerialization.MutabilityOptions(), format: nil) as AnyObject!
            var localFilePath = (resumeDictionary?["NSURLSessionResumeInfoLocalPath"] as? String)

            if localFilePath == nil || (localFilePath?.characters.count)! < 1 {
                localFilePath = (NSTemporaryDirectory() as String) + (resumeDictionary["NSURLSessionResumeInfoTempFileName"] as! String)
            }

            let fileManager : FileManager! = FileManager.default
            debugPrint("resume data file exists: \(fileManager.fileExists(atPath: localFilePath! as String))")
            return fileManager.fileExists(atPath: localFilePath! as String)
        } catch let error as NSError {
            debugPrint("resume data is nil: \(error)")
            return false
        }
    }

}



