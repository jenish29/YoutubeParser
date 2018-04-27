////
////  DownloaderViewController.swift
////  Youtube
////
////  Created by Jenish on 7/21/17.
////  Copyright © 2017 pc. All rights reserved.
////
//
//import UIKit
//
//class DownloaderViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, URLSessionDownloadDelegate {
//downloa
//    private var downloadArray : NSMutableArray?
//    private var shouldDownlaod : Bool = true
//
//    @IBOutlet var tableView: UITableView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if UserDefaults.standard.value(forKey: "isDownloading") == nil {
//            UserDefaults.standard.setValue(false, forKey: "isDownloading")
//        }
//        if let data = UserDefaults.standard.object(forKey: "downloadsssss") {
//            downloadArray = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? NSMutableArray
//        }
//        self.tableView.reloadData()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//
//    }
//
//    private var session : URLSession? // urlsession to download
//    private var task  : URLSessionTask? // urlsession task
//    private var isDownloading : Bool = false
//
//    private var currentDownloadingCell : DownloadCell? // currentcell that is being downlaoded
//    private var currentDownloadData : Download? // current downlaod data
//    private var cameFrom : Int? // indicating which indexpath.row the currentdownload came from
//
//
//    func download(downloadObj:Download, cell : DownloadCell) {
//
//        if UserDefaults.standard.value(forKey: "isDownloading") as! Bool == true {
//            let task = UserDefaults.standard.value(forKey: "task") as! URLSessionTask
//            let session = UserDefaults.standard.value(forKey: "session") as! URLSession
//
//            self.task = task
//            self.session = session
//
//            task.resume()
//
//            return
//        }
//
//        currentDownloadData = downloadObj
//        currentDownloadingCell = cell
//
//        let videoUrl = URL(string: downloadObj.videoLink)
//
//        let sessionsConfig = URLSessionConfiguration.background(withIdentifier: downloadObj.videoId)
//        session = URLSession(configuration: sessionsConfig, delegate: self, delegateQueue: OperationQueue.main)
//        let request = URLRequest(url: videoUrl!)
//
//        UserDefaults.standard.setValue(true, forKey: "isDownloading")
//
//        self.task = session!.downloadTask(with: request)
//
//        UserDefaults.standard.setValue(task, forKey: "task")
//        UserDefaults.standard.setValue(session, forKey: "session")
//
//        task?.resume()
//
//
//    }
//
//    //url session delegate methods
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        DispatchQueue.main.async {
//
//            if self.currentDownloadingCell != nil && self.cameFrom != nil {
//                if let indexes = self.tableView.indexPathsForVisibleRows {
//                    for index in  indexes {
//                        if index.row == self.cameFrom  {
//                            self.currentDownloadingCell!.downloadProgress.text = "\(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) * 100)"
//                        }
//                    }
//
//                }
//
//
//            }
//
//        }
//
//    }
//
//
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//
//        UserDefaults.standard.setValue(false, forKey: "isDownloading")
//
//        if self.currentDownloadData == nil || self.downloadArray == nil {return}
//
//        self.session?.finishTasksAndInvalidate()
//        self.task?.cancel()
//
//        self.currentDownloadData?.isDownloadComplete = true
//
//        self.downloadArray?.removeObject(at: cameFrom!)
//        self.downloadArray?.insert(currentDownloadData!, at: cameFrom!)
//
//        let documentsUrl : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
//        let destinationUrl = documentsUrl.appendingPathComponent((currentDownloadData?.videoId)! + ".mp4")
//
//        do {
//            try FileManager.default.copyItem(at: location, to: destinationUrl)
//        }   catch {
//            return
//        }
//
//        if let downloadArray = downloadArray {
//            let data = NSKeyedArchiver.archivedData(withRootObject: downloadArray)
//            UserDefaults.standard.setValue(data, forKey: "downloadsssss")
//
//            self.session = nil
//            self.task = nil
//            self.isDownloading = false
//
//            self.currentDownloadingCell = nil
//
//        }
//
//          self.tableView.reloadData()
//
//    }
//
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//
//        if error != nil {
//            do {
//                let err = error as NSError?
//                if let data =  err!.userInfo[NSURLSessionDownloadTaskResumeData] {
//                    let nwTask =  session.downloadTask(withResumeData: data as! Data)
//                    self.task?.cancel()
//                    self.task = nwTask
//                    self.task?.resume()
//
//                }
//            }
//
//        }
//    }
//
//
//    //end urlsession delegate methods
//
//    //tableview delegate methods
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let downloadArray = downloadArray { return downloadArray.count } else{ return 0 }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DownloadCell
//
//        let data = downloadArray?[indexPath.row] as! Download
//
//        cell.videoId = data.videoId
//
//        if data.isDownloadComplete == nil {
//
//                self.cameFrom = indexPath.row
//                self.download(downloadObj: data, cell: cell)
//
//        }
//
//        cell.videoTitle.text = data.videoTitle
//        cell.videoImage.image = data.image
//
//        if data.isDownloadComplete == nil{
//            cell.downloadProgress.text = "0%"
//
//        }else{
//            cell.downloadProgress.text = "100%"
//        }
//
//
//        return cell
//    }
//
//
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
//        let curr  = self.downloadArray?[indexPath.row] as! Download
//
//        //creating hashable data
//        let videoData = videoInfo(videoId: curr.videoId!, videoUrl: curr.videoLink, videoImage: nil, videoTitle: nil)
//        let hashAbleArray = ["videoData" : videoData]
//
//        //posting notification
//        NotificationCenter.default.post(name: NSNotification.Name("open"), object: self)
//        NotificationCenter.default.post(name: NSNotification.Name("playVideo"), object: nil, userInfo: hashAbleArray)
//
//    }
//    //end tableview delegate
//
//    @IBAction func dismissView(_ sender: UIButton) {
//        self.willMove(toParentViewController: self.parent)
//        self.removeFromParentViewController()
//        self.view.removeFromSuperview()
//    }
//
//}
//
//
//
//
//

