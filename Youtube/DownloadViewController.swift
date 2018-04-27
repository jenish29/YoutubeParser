//
//  DownloadViewController.swift
//  Youtube
//
//  Created by Jenish on 8/8/17.
//  Copyright © 2017 pc. All rights reserved.
//

import UIKit

class DownloadViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet var tableView: UITableView!
    var downloads : NSMutableArray?
    var downloadManagers = [DownloadManager]()

    override func viewDidLoad() {
        super.viewDidLoad()
       UserDefaults.standard.setValue(false, forKey: "isDownloading")
        //getting downloads from userdefaults
        if let downloadsData = UserDefaults.standard.object(forKey: "downloads") {
            //decoding data
            let downloads = NSKeyedUnarchiver.unarchiveObject(with: downloadsData as! Data) as? NSMutableArray
            self.downloads = downloads!

            //adding to downloads
            addDownloads()
        }
    }

    func addDownloads() {
        for download in downloads! {
            if let download = download as? DownloadInfo {
                let downloader = Downloader()
                downloader.backgroundIdentifier = download.videoId

                downloader.makeSession()

                let dwn = DownloadManager(videoUrl: download.videoLink)
                dwn.videoId = download.videoId
                dwn.downloader = downloader
                dwn.downloader.delegate = dwn
                dwn.viewController = self
                
                downloadManagers.append(dwn)
            }
        }
    }

    //dismissing the view
    @IBAction func dismissView(_ sender: UITapGestureRecognizer) {
        self.willMove(toParentViewController: self.parent)
        self.removeFromParentViewController()
        self.view.removeFromSuperview()

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadManagers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DownloadCell
        let isDownloading = UserDefaults.standard.value(forKey: "isDownloading") as? Bool

        let download = downloadManagers[indexPath.row]
        let dwn = downloads![indexPath.row] as! DownloadInfo

        if dwn.isDownloadComplete == nil  &&
            (isDownloading == nil || (isDownloading != nil && isDownloading == false))
        {
            download.download()
        }

        cell.videoImage.image = dwn.image
        cell.videoTitle.text = dwn.videoTitle

        download.indexPath = indexPath
        download.cell = cell
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let curr  = self.downloads?[indexPath.row] as! DownloadInfo

            //creating hashable data
        let videoData = videoInfo(videoId: curr.videoId!, videoUrl: curr.videoLink, videoImage: nil, videoTitle: nil)
        let hashAbleArray = ["videoData" : videoData]

        //posting notification
        NotificationCenter.default.post(name: NSNotification.Name("open"), object: self)
        NotificationCenter.default.post(name: NSNotification.Name("playVideo"), object: nil, userInfo: hashAbleArray)
    }

    func showAlert(message:String) {
        let alert = UIAlertController(title: "alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func changeData(videoId : String, isDownloadComplete : Bool?, currentlyGetting : Bool?) {

        //changing the value for the video indicating that video has been downloaded
        var download : DownloadInfo = DownloadInfo()
        var row = -1

        // getting the downloaded object from the array
        for obj in downloads! {
            //casting to Download object and increasing row number
            let curr = obj as! DownloadInfo
            row += 1

            if curr.videoId == videoId {
                download = curr
                break
            }
        }

        //changing the value in download obj
        download.isDownloadComplete = isDownloadComplete
        download.currentlyGettingNew = currentlyGetting

        downloads?.replaceObject(at: row, with: download)

        //changing that value in userDefaults
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: downloads!)
        UserDefaults.standard.setValue(encodedData, forKey: "downloads")

    }
}




