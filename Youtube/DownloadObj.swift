////
////  DownloadObj.swift
////  Youtube
////
////  Created by Jenish on 8/5/17.
////  Copyright © 2017 pc. All rights reserved.
////
//
//import Foundation
//
//public enum DownloadState {
//    case unkown
//
//    case waiting
//    case downloading
//    case pausing
//    case paused
//    case completed
//
//    //Cancelled so no coming back
//    case cancelled
//}
//
//public protocol DownloaderDelegate: class {
//    func download(_ download: Downloader, stateChanged toState : DownloadState, fromState : DownloadState)
//    func download(_ download: Downloader, progressChanged fractionCompleted: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
//
//}
//
//public protocol DownloadManagerDelegate: class {
//    func download(_ manager: DownloadManager, failedToMoveFileForDownload: Downloader, error: NSError)
//    func download(_ manager: DownloadManager, completedDownload: Downloader, error: NSError?)
//    func download(_ manager: DownloadManager, receivedChallengeForDownload: Downloader, challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
//    func download(_ manager: DownloadManager, backgroundSessionBecameInvalidWithError: NSError?)
//}
//
//
//private struct Constants {
//    static let defaultBackgroundSessionIdentifier = "com.jenish"
//    static let downloadsLockQueueIdentifier = "com.jenish.queue"
//}
//
//open class Downloader : NSObject {
//    fileprivate let manager: DownloadManager
//
//    open weak var delegate : DownloaderDelegate?
//
//    fileprivate var downloadTask: URLSessionDownloadTask?
//
//    open fileprivate(set) var lastState: DownloadState
//    open fileprivate(set) var state: DownloadState {
//        willSet {
//            lastState = state
//        }
//        didSet {
//            delegate?.download(self, stateChanged: state, fromState: lastState)
//        }
//    }
//
//    open fileprivate(set) var totalBytesExpectedToWrite: Int64
//    open fileprivate(set) var totalBytesWritten: Int64 {
//        didSet {
//            if totalBytesExpectedToWrite > 0 {
//                fractionCompleted = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
//            } else {
//                fractionCompleted = 0
//            }
//
//            delegate?.download(self, progressChanged: fractionCompleted, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
//        }
//    }
//
//    open var url: URL
//    open var resumeData: Data?
//
//    open var fractionCompleted: Float = 0
//
//    fileprivate init(url: URL, manager: DownloadManager) {
//        self.url = url
//        self.manager = manager
//        self.state = .unkown
//        self.lastState = .unkown
//        self.totalBytesExpectedToWrite = 0
//        self.totalBytesWritten = 0
//    }
//
//    open func resume() {
//        if let resumeData = resumeData {
//            downloadTask?.cancel()
//            downloadTask = manager.backgroundSession.downloadTask(withResumeData: resumeData)
//            self.resumeData = nil
//        }
//
//        if downloadTask == nil {
//          downloadTask = manager.backgroundSession.downloadTask(with: url)
//        }
//        
//        state = .waiting
//        downloadTask?.resume()
//    }
//
//    // Returns resume data
//    open func pause(_ completionHandler: ((Data?) -> Void)? = nil) {
//        state = .pausing
//        downloadTask?.cancel(byProducingResumeData: { (data) -> Void in
//            self.state = .paused
//            self.resumeData = data
//            completionHandler?(data)
//        })
//    }
//
//    open func cancel() {
//        downloadTask?.cancel()
//        state = .cancelled
//    }
//
//    open func remove() {
//        cancel()
//    }
//
//}
//
//public func ==(lhs: Downloader, rhs: Downloader) -> Bool {
//    return (lhs.url == rhs.url)
//}
//
//open class DownloadManager : NSObject, URLSessionDownloadDelegate, URLSessionDelegate {
//
//    open weak var delegate: DownloadManagerDelegate?
//
//    open var downloads: Array<Downloader>
//
//    fileprivate let downloadLockQueue: DispatchQueue
//
//    open var backgroundSessionCompletionHandler: (() -> Void)?
//
//    open var downloadCompletionHandler: ((Downloader, URLSession, URL) -> URL?)?
//
//    fileprivate let backgroundSessionIdentifier: String
//
//    fileprivate lazy var backgroundSession: URLSession = self.newBackgroundUrlUsession()
//
//    public required init(backgroundSessionIdentifier: String) {
//        self.downloads = Array<Downloader>()
//        self.downloadLockQueue = DispatchQueue(label: Constants.downloadsLockQueueIdentifier, attributes: [])
//        self.backgroundSessionIdentifier = backgroundSessionIdentifier
//
//        super.init()
//    }
//
//    fileprivate func newBackgroundUrlUsession() -> URLSession {
//        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: backgroundSessionIdentifier)
//        return URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: nil)
//    }
//
//    fileprivate func handleDownloadTaskWithProgress(_ downloadTask: URLSessionDownloadTask, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//
//        if let download = getDownloadFromTask(downloadTask) {
//            if download.state != .downloading {
//                download.state = .downloading
//            }
//
//            download.totalBytesExpectedToWrite = totalBytesExpectedToWrite
//            download.totalBytesWritten = totalBytesWritten
//        }
//
//
//
//
//    }
//
//    fileprivate func getDownloadFromTask(_ task: URLSessionTask) -> Downloader? {
//        var download: Downloader?
//
//        if let url = task.originalRequest?.url {
//            downloadLockQueue.sync {
//                if let foundAtIndex = self.downloads.index(where: {$0.url == url}) {
//                    download = self.downloads[foundAtIndex]
//                }
//            }
//        }
//
//        return download
//    }
//
//
//    open func downloadWithURL(_ url: URL, delegate: DownloaderDelegate?, resumeData: Data? = nil) -> Downloader {
//        var download = Downloader(url: url, manager: self)
//
//        downloadLockQueue.sync {
//            if let foundAtIndex = self.downloads.index(where: { $0 == download }) {
//                download = self.downloads[foundAtIndex]
//            } else {
//                self.downloads.append(download)
//            }
//        }
//
//        download.delegate = delegate
//        download.resumeData = resumeData
//        
//        return download
//    }
//
//    open func resumeAll() {
//        downloadLockQueue.sync {
//            _ = self.downloads.map { $0.resume() }
//        }
//    }
//
//    open func pauseAll() {
//        downloadLockQueue.sync {
//            _ = self.downloads.map { $0.pause() }
//        }
//    }
//
//    open func cancelAll() {
//        downloadLockQueue.sync {
//            _ = self.downloads.map { $0.cancel() }
//        }
//    }
//
//    open func removeAll() {
//        downloadLockQueue.sync {
//            _ = self.downloads.map { $0.cancel() }
//            self.downloads.removeAll()
//        }
//    }
//
//
//    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        if let download = getDownloadFromTask(downloadTask) {
//            download.state = .completed
//            if let moveTo = downloadCompletionHandler?(download, session, location) {
//                do {
//                    try FileManager.default.moveItem(at: location, to: moveTo)
//                } catch let error as NSError {
//                    self.delegate?.download(self, failedToMoveFileForDownload: download, error: error)
//                }
//            }
//        }
//    }
//
//    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
//        handleDownloadTaskWithProgress(downloadTask, totalBytesWritten: fileOffset, totalBytesExpectedToWrite: expectedTotalBytes)
//    }
//
//    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        handleDownloadTaskWithProgress(downloadTask, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
//    }
//
//    // MARK:- NSURLSessionTaskDelegate
//
//    open func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        if let download = getDownloadFromTask(task) {
//            delegate?.download(self, receivedChallengeForDownload: download, challenge: challenge, completionHandler: completionHandler)
//        }
//    }
//
//    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        if let download = getDownloadFromTask(task) {
//            delegate?.download(self, completedDownload: download, error: error as NSError?)
//        }
//    }
//
//    // MARK:- NSURLSessionDelegate
//
//    open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
//        delegate?.download(self, backgroundSessionBecameInvalidWithError: error as NSError?)
//    }
//
//    open func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
//        // If there are no tasks remaining, then the session is complete.
//        session.getTasksWithCompletionHandler { (_, _, downloadTasks) -> Void in
//            if downloadTasks.count == 0 {
//                DispatchQueue.main.async {
//                    self.backgroundSessionCompletionHandler?()
//                    self.backgroundSessionCompletionHandler = nil
//                }
//            }
//        }
//    }
//
//
//}
