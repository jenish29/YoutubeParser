//
//  DownloadManager.swift
//  Downloader
//
//  Created by Jenish on 8/13/17.
//  Copyright © 2017 Jenish. All rights reserved.
//

import Foundation
import UIKit
class DownloadManager : NSObject, DownloaderDelegate {
    var cell : DownloadCell?
    var videoUrl : String?
    var downloader : Downloader!
    var viewController : DownloadViewController!
    var indexPath : IndexPath!
    var videoId : String!

    required init(videoUrl: String) {
        self.videoUrl = videoUrl
        super.init()
    }

    func download() {
        DispatchQueue.global().async {
            sleep(2)
            let isDownloading = UserDefaults.standard.value(forKey: "isDownloading") as? Bool
            if isDownloading == nil || (isDownloading != nil && isDownloading == false) {
                UserDefaults.standard.setValue(true, forKey: "isDownloading")
                let url = URL(string: self.videoUrl!)
                self.downloader.download(url: url)
            }
        }
    }
    func resume(data : Data?,has403 : Bool) {
        if !has403 {
            if downloader != nil{
                downloader.download(url: nil)
            }

        }else{
            UserDefaults.standard.setValue(false, forKey: "isDownloading")
        }
    }

    //download data came
    func urlSession(didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if (viewController) != nil {
            DispatchQueue.main.async {
                let visibileRow = self.viewController.tableView.indexPathsForVisibleRows

                if self.indexPath != nil && visibileRow != nil && (visibileRow?.contains(self.indexPath))! {
                    let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)

                    self.cell?.videoProgress.setProgress(progress, animated: true)
                    self.cell?.videoProgressText.text = "\(progress * 100)"
                }

            }
        }

    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let err = Has403()
        err.parse(viewController: viewController, urlString: videoUrl!) { (_) in

        }

            //saving video location
            let documentUrl : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
            let videoStorageDestination = documentUrl.appendingPathComponent(self.videoId + ".mp4")

            do{
                try FileManager.default.copyItem(at: location, to: videoStorageDestination)
                //called to change data in video array
                self.self.viewController.changeData(videoId: self.videoId, isDownloadComplete:  true, currentlyGetting: nil)
                UserDefaults.standard.setValue(false, forKey: "isDownloading")
                self.viewController.tableView.reloadData()

            }catch let error {
                viewController.showAlert(message: error.localizedDescription)
                UserDefaults.standard.setValue(false, forKey: "isDownloading")
                self.viewController.tableView.reloadInputViews()
                self.viewController.showAlert(message: error.localizedDescription)
            }

        
    }

    func completeWitherror(error: Error?) {
        viewController.showAlert(message: "\(error)")
    }

}



