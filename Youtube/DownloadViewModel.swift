////
////  DownloadViewModel.swift
////  Youtube
////
////  Created by Jenish on 8/8/17.
////  Copyright © 2017 pc. All rights reserved.
////
//
//import Foundation
//import UIKit
//class Downld {
//    var viewModel = DownloadCellViewModel()
//
//    let videoId: String
//    let videoTitle: String
//    let videoUrl : URL
//    let videoImage : UIImage
//
//    let download : Download
//
//    init(videoTitle:String, videoUrl: URL, videoId: String, videoImage : UIImage) {
//        self.videoUrl = videoUrl
//        self.videoTitle = videoTitle
//        self.videoId = videoId
//        self.videoImage = videoImage
//        self.download = downloader.downloadWithURL(videoUrl, videoId: videoId, delegate: nil)
//    }
//
//    func listenForChanges() {
//        viewModel.videoTitle = videoTitle
//        download.delegate = viewModel
//    }
//}
//
//class DownloadCellViewModel: DownloadDelegate {
//    var videoTitle = ""
//    var progress : Float = 0
//    var cell : DownloadTableViewCell?
//
//    func download(_ download: Download, progressChanged fractionCompleted: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        if let cell = cell {
//            DispatchQueue.main.async {
//                cell.progressView.setProgress(fractionCompleted, animated: true)
//            }
//        }
//    }
//
//    func download(_ download: Download, stateChanged toState: DownloadState, fromState: DownloadState) {
//
//    }
//}
//
//class DownloadViewModel: DownloadManagerDelegate {
//    var downloads = Array<Downld>()
//
//    func addDownload(_ download: Downld) {
//        download.listenForChanges()
//        downloads.append(download)
//    }
//
//    func download(_ manager: DownloadManager, completedDownload: Download, error: NSError?) {
//        print("finished downloading")
//    }
//}
//
//

