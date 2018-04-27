////
////  DownloadController.swift
////  Youtube
////
////  Created by pc on 7/27/17.
////  Copyright © 2017 pc. All rights reserved.
////
//
//import UIKit
//
//class DownloadController: UIViewController, UITableViewDelegate,UITableViewDataSource,URLSessionDownloadDelegate {
//
//    //download objects
//    private var downloadObjects : NSMutableArray?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        //getting downloads from userdefaults
//        if let downloadsData = UserDefaults.standard.object(forKey: "downloads") {
//            //decoding data
//            let downloads = NSKeyedUnarchiver.unarchiveObject(with: downloadsData as! Data) as? NSMutableArray
//            self.downloadObjects = downloads!
//        }
//
//        self.downloadTableView.reloadData()
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        //getting downloads from userdefaults
//        if let downloadsData = UserDefaults.standard.object(forKey: "downloads") {
//            //decoding data
//            let downloads = NSKeyedUnarchiver.unarchiveObject(with: downloadsData as! Data) as? NSMutableArray
//            self.downloadObjects = downloads!
//        }
//        downloadTableView.reloadData()
//    }
//
//    @IBAction func dismissView(_ sender: UIButton) {
//        self.willMove(toParentViewController: self.parent)
//        self.removeFromParentViewController()
//        self.view.removeFromSuperview()
//    }
//
//    // the main tableView
//    @IBOutlet var downloadTableView: UITableView!
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return downloadObjects == nil ? 0 : (downloadObjects?.count)!
//    }
//
//    private var currentCellInView = false // if currentDownloadingCell is in the view
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DownloadCell
//
//        // setting up the cell
//        if cell == currentDownloadingCell { currentCellInView = true }
//
//        let downloadObj = downloadObjects?[indexPath.row] as! DownloadInfo
//
//        //videoImage
//        let videoImage = downloadObj.image
//        let videoTitle = downloadObj.videoTitle
//
//        cell.videoImage.image = videoImage!
//        cell.videoTitle.text
//            = videoTitle!
//
//        startDownload(row: indexPath.row, cell: cell)
//        return cell
//
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
//        //getting the currentObject
//        let curr = downloadObjects?[indexPath.row] as! DownloadInfo
//
//        //creating hashable data
//        let videoData = videoInfo(videoId: curr.videoId!, videoUrl: curr.videoLink, videoImage: nil, videoTitle: nil)
//        let hashAbleArray = ["videoData" : videoData]
//
//        //posting notification
//        NotificationCenter.default.post(name: NSNotification.Name("open"), object: self)
//        NotificationCenter.default.post(name: NSNotification.Name("playVideo"), object: nil, userInfo: hashAbleArray)
//
//
//    }
//
//    //end tableView functions
//
//    private var currentDownloadingCell : DownloadCell?
//    private var downloadTask : URLSessionTask?
//    private var downloadSession : URLSession?
//
//    //function that will start downloading
//    func startDownload(row:Int,cell:DownloadCell) {
//        let downloadObj = downloadObjects?[row] as! DownloadInfo
//
//        //if the video has already been downloaded
//        // if there already exits a download in progress then just return
//        if downloadObj.isDownloadComplete != nil || (UserDefaults.standard.value(forKey: "currentlyDownloading") != nil &&
//            UserDefaults.standard.value(forKey: "currentlyDownloading") as! Bool == true
//            && UserDefaults.standard.value(forKey: "downloadObjLocation") != nil && row != UserDefaults.standard.value(forKey: "downloadObjLocation") as! Int) {
//            return
//        }
//
//        //Setting true to isDownloading in userdefaults
//        UserDefaults.standard.setValue(true, forKey: "currentlyDownloading")
//        UserDefaults.standard.setValue(downloadObj.videoId!, forKey: "currentDownloadVideoId")
//
//        Has403().parse(urlString: downloadObj.videoLink, completionHandler: { (has) in
//            //the link has become invalid
//            if has && downloadObj.currentlyGettingNew == nil {
//                //Setting true to isDownloading in userdefaults
//                UserDefaults.standard.setValue(false, forKey: "currentlyDownloading")
//                UserDefaults.standard.setValue(-1, forKey: "currentDownloadVideoId")
//                UserDefaults.standard.setValue(-1,forKey: "downloadObjLocation")
//                self.changeData(videoId: downloadObj.videoId!, isDownloadComplete: nil,currentlyGetting: true)
//
//                let parser = KeepvidParser()
//                parser.parse(string: downloadObj.videoId, completionHandler: {
//                    let urlString = (parser.getData()[0] as! NSMutableDictionary).value(forKey: "url") as! String
//                    downloadObj.videoLink = urlString
//                    downloadObj.isDownloadComplete = nil
//                    self.downloadObjects?.replaceObject(at: row, with: downloadObj)
//
//                    let val = UserDefaults.standard.value(forKey: "downloadObjLocation") as? Int
//
//                    if val != nil && val != -1 {
//                        UserDefaults.standard.setValue(row, forKey: "downloadObjLocation")
//                        UserDefaults.standard.setValue(true, forKey: "currentlyDownloading")
//                    }
//
//                })
//
//                return
//            }
//
//            if downloadObj.videoId! != UserDefaults.standard.value(forKey: "currentDownloadVideoId") as! String
//            { return }
//
//            //this value will be set to true if we need to resume data
//            var isRowSame = false
//            if UserDefaults.standard.value(forKey: "downloadObjLocation") != nil &&
//                row == UserDefaults.standard.value(forKey: "downloadObjLocation") as! Int {
//                isRowSame = true
//            }
//
//            // Start download if there are no downloading items
//            //changing it in the userDefaults
//            let data = NSKeyedArchiver.archivedData(withRootObject: self.downloadObjects!)
//            UserDefaults.standard.setValue(data, forKey: "downloads")
//
//            //adding where the object came from
//            UserDefaults.standard.setValue(row, forKey: "downloadObjLocation")
//
//            self.currentDownloadingCell = cell
//            //download link and video id to set background with identifier
//            let downloadLink = downloadObj.videoLink!
//            let videoId = downloadObj.videoId!
//
//            // setting up UrlConfiguration and urlsession
//            let urlConfig = URLSessionConfiguration.background(withIdentifier: videoId)
//            let downloadSession = URLSession(configuration: urlConfig, delegate: self, delegateQueue: OperationQueue.main)
//
//            //setting up url request and downloadTask
//            let downloadUrl = URL(string: downloadLink)
//            let request = URLRequest(url: downloadUrl!)
//
//            if self.downloadTask != nil {
//                self.downloadTask?.resume()
//            }
//            //if we need to resume data then we dont start this downloadtask
//            if !isRowSame {
//                //start the download
//                let downloadTask = downloadSession.downloadTask(with: request)
//                downloadTask.resume()
//                self.downloadTask = downloadTask
//                self.downloadSession = downloadSession
//            }
//
//        })
//
//    }
//
//    // Download session did recive data
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        DispatchQueue.main.async {
//            for indexPath in self.downloadTableView.indexPathsForVisibleRows! {
//                // if the row is visible
//                let row = UserDefaults.standard.value(forKey: "downloadObjLocation") as! Int
//                if row == indexPath.row {
//                    //% of download
//                    let downloadProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) * 100
//                    self.currentDownloadingCell?.downloadProgress.text = "\(downloadProgress)"
//                    break
//                }
//            }
//
//
//        }
//
//    }
//
//    // Download did finish downloading
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//
//        //changing value so next download begins
//        UserDefaults.standard.setValue(false, forKey: "currentlyDownloading")
//        UserDefaults.standard.set(-1, forKey: "downloadObjLocation")
//
//        //getting the video id for the currentDownload
//        let videoId = UserDefaults.standard.value(forKey: "currentDownloadVideoId") as! String
//
//        //ending the session
//        session.finishTasksAndInvalidate()
//
//        //saving video location
//        let documentUrl : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
//        let videoStorageDestination = documentUrl.appendingPathComponent(videoId + ".mp4")
//
//        self.downloadSession = nil
//        self.downloadTask = nil
//
//        //writing the video from location to the place
//        do {
//            try FileManager.default.copyItem(at: location, to: videoStorageDestination)
//
//            //called to change data in video array
//            changeData(videoId: videoId, isDownloadComplete:  true, currentlyGetting: nil)
//
//
//        }catch (let error) {
//            if error.localizedDescription.contains("already exists") {
//                changeData(videoId: videoId, isDownloadComplete: true, currentlyGetting: nil)
//            }
//        }
//
//            downloadTableView.reloadData()
//
//    }
//
//
//    //called to change data in userdefaults
//    private func changeData(videoId : String, isDownloadComplete : Bool?, currentlyGetting : Bool?) {
//
//        //changing the value for the video indicating that video has been downloaded
//        var download : DownloadInfo = DownloadInfo()
//        var row = -1
//
//        // getting the downloaded object from the array
//        for obj in downloadObjects! {
//            //casting to Download object and increasing row number
//            let curr = obj as! DownloadInfo
//            row += 1
//
//            if curr.videoId == videoId {
//                download = curr
//                break
//            }
//        }
//
//        //changing the value in download obj
//        download.isDownloadComplete = isDownloadComplete
//        download.currentlyGettingNew = currentlyGetting
//
//        downloadObjects?.replaceObject(at: row, with: download)
//
//        //changing that value in userDefaults
//        let encodedData = NSKeyedArchiver.archivedData(withRootObject: downloadObjects!)
//        UserDefaults.standard.setValue(encodedData, forKey: "downloads")
//
//    }
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        //if there is data to be downloaded
//        if error != nil {
//            //conver error to nserror
//            let err = error! as NSError
//                //get resumer data if there is otherwise resume current session\
//                if let resumeData = err.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
//                    //resume downloadtask with data already downloaded data
//                    self.downloadTask = session.downloadTask(withResumeData: resumeData)
//                    self.downloadTask?.resume()
//
//                    self.downloadSession = session
//                }
//        }
//    }
//
//}
//
////custom download cell
//class DownloadCell : UITableViewCell {
//    @IBOutlet var videoImage: UIImageView!
//    @IBOutlet var videoTitle: UILabel!
//    @IBOutlet var downloadProgress: UILabel!
//    var videoId : String = ""
//}
//
//

