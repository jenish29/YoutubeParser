////  The main Download class
//
//import Foundation
//
//open class Download : NSObject {
//    //download manager
//    fileprivate let manager: DownloadManager
//
//    //delegate 
//    open weak var delegate: DownloadDelegate?
//
//    //download states
//    open public(set) var lastState : DownloadState
//    open public(set) var state: DownloadState {
//        willSet{
//            lastState = state
//        }
//
//        didSet {
//            delegate?.download(self, stateChanged: state, fromState: lastState)
//        }
//    }
//
//    //the bytes written 
//    open var fractionCompleted: Float = 0
//    open public(set) var totalBytesExpectedToWrite: Int64
//    open public(set) var totalBytesWritten: Int64 {
//        didSet {
//            if totalBytesExpectedToWrite > 0 {
//                fractionCompleted = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
//            } else {
//                fractionCompleted = 0
//            }
//            delegate?.download(self, progressChanged: fractionCompleted, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
//        }
//    }
//
//    //main url and resume data
//    open var videoUrl: URL
//    open var videoId: String
//    open var resumeData: Data?
//
//    //initializing
//    init(videoUrl: URL, videoId: String, manager: DownloadManager) {
//        self.videoUrl = videoUrl
//        self.videoId = videoId
//        self.manager = manager
//        self.lastState = .unkown
//        self.state = .unkown
//        self.totalBytesExpectedToWrite = 0
//        self.totalBytesWritten = 0
//    }
//
//    fileprivate var downloadTask: URLSessionDownloadTask?
//
//    //resume the download if resume data exits otherwise start new
//    func resume() {
//        //checks if resume data exits
//        if let resumeData = resumeData {
//            downloadTask?.cancel()
//            downloadTask = manager.backgroundsession.downloadTask(withResumeData: resumeData)
//            self.resumeData = nil
//        }
//
//        if downloadTask == nil {
//           downloadTask = manager.backgroundsession.downloadTask(with: videoUrl)
//        }
//        print(resumeData)
//        state = .waiting
//        downloadTask?.resume()
//    }
//
//    //pause with resume data
//    func pause(_ completionHandler: ((Data?) -> Void)? = nil) {
//        state = .pausing
//        downloadTask?.cancel(byProducingResumeData: { (data) -> Void in
//            self.state = .paused
//            self.resumeData = data
//            completionHandler?(data)
//        })
//    }
//
//
//}

