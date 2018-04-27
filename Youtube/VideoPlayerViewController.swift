//
//  VideoPlayerViewController.swift
//  Youtube
//
//  Created by pc on 7/18/17.
//  Copyright © 2017 pc. All rights reserved.
//

import UIKit
import AVFoundation


class VideoPlayerViewController: UIViewController {
    
    @IBOutlet var playerView: UIView!
    @IBOutlet var forwardView: UIView!
    @IBOutlet var rewindView: UIView!
    @IBOutlet var videoSeekerSlider: UISlider!
    @IBOutlet var progressLabel: UILabel!
    private var session : URLSession!
    private var task : URLSessionTask!
    
    var videoImage : UIImage!
    var videoTitle : String!
    var videoId : String!
    
 
    override func viewWillAppear(_ animated: Bool) {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissView))
        swipeGesture.direction = .down
        NotificationCenter.default.addObserver(self, selector: #selector(orienTationChange), name:  NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        if let task = task {
            task.resume()
        }
        view.addGestureRecognizer(swipeGesture)
        
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func dismissView() {
        videoPlayer?.pause()
        videoPlayer?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
        videoPlayer?.replaceCurrentItem(with: nil)
        self.willMove(toParentViewController: self.parent)
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
      
    }
    

    
    func orienTationChange() {
        videoPlayerLayer?.frame = playerView.frame
        view.bringSubview(toFront: playerView)
        view.bringSubview(toFront: videoSeekerSlider)
    }
    
    private var videoPlayer : AVPlayer? = nil
    private var videoPlayerLayer : AVPlayerLayer? = nil

    var videoUrl = "https://redirector.googlevideo.com/videoplayback?ms=au&ratebypass=yes&ipbits=0&mv=m&lmt=1499941031800196&sparams=dur,ei,id,ip,ipbits,itag,lmt,mime,mm,mn,ms,mv,pl,ratebypass,requiressl,source,expire&expire=1500465645&mime=video/mp4&source=youtube&key=yt6&itag=18&ei=jfVuWauyOczjuALbmpboAg&ip=107.178.194.15&mt=1500443871&id=o-AHzqvSzifrxv-XK0enzTWC0Hn6rB1OhUe2V1oSwQWpIn&dur=7282.079&requiressl=yes&mm=31&signature=7917A7291C6170D6BE0A454838D9651A1F94FA5C.716A6DF78F00E6093A06141BA3840E0FDA0C26C8&pl=28&mn=sn-vgqsrn7s"
   
    
    
    func playVideo(){
        if let url = URL(string: videoUrl) {
            
            let documentsUrl : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
            let destinationUrl = documentsUrl.appendingPathComponent(videoId+".mp4")
        
            let isVideoSaved = FileManager.default.fileExists(atPath: destinationUrl.path)
            
            var player = AVPlayer()
            
            if isVideoSaved {
                 player = AVPlayer(url: destinationUrl)
            }else{
                player = AVPlayer(url: url)
            }
            

            let playerLayer = AVPlayerLayer(player: player)
            
   
            playerLayer.frame = playerView.frame
            
            self.playerView.layer.addSublayer(playerLayer)
            
            let tapGesture  = UITapGestureRecognizer(target: self, action: #selector(pauseVideo))
            playerView.addGestureRecognizer(tapGesture)
            
            let forGesture = UITapGestureRecognizer(target: self, action: #selector(forwardVideo))
            forwardView.addGestureRecognizer(forGesture)
            forGesture.numberOfTapsRequired = 2
                            let reverseGesture = UITapGestureRecognizer(target: self, action: #selector(reverseVideo))
            rewindView.addGestureRecognizer(reverseGesture)
            reverseGesture.numberOfTapsRequired = 2
            
            
            player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            player.automaticallyWaitsToMinimizeStalling = false
            
            
            player.play()
            self.videoPlayer = player
            self.videoPlayerLayer = playerLayer
            
            
        }
    }
    
    func pauseVideo(){
        if let videoPlayer = videoPlayer {
            if (videoPlayer.isPlaying) {
                videoPlayer.pause()
                addTotalVideoTime()
            }else{
                videoPlayer.play()
            }
        }
        
    }
    
    func forwardVideo(){
        
        if let videoPlayer = videoPlayer {
            let duration = videoPlayer.currentTime()
            
            videoPlayer.pause()
            
            let seconds = CMTimeGetSeconds(duration)
            let toSkip = seconds+10.0
            let time = CMTime(value: Int64(toSkip), timescale: 1)
            
            videoPlayer.seek(to: time) { (seeked) in
                videoPlayer.play()
            }
            
        }
    }
    
    func reverseVideo(){
        if let videoPlayer = videoPlayer {
            let duration = videoPlayer.currentTime()
            
            videoPlayer.pause()
            
            let seconds = CMTimeGetSeconds(duration)
            let toSkip = seconds-100.0
            let time = CMTime(value: Int64(toSkip), timescale: 1)
            
            videoPlayer.seek(to: time) { (seeked) in
                videoPlayer.play()
            }
        }
    }
    
    @IBOutlet var controlView: UIView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var currentTimeLabel: UILabel!
    
    func addTotalVideoTime() {
        if let duration = videoPlayer?.currentItem?.duration{
            
            var totalTime = CMTimeGetSeconds(duration)
            guard !(totalTime.isNaN || totalTime.isInfinite) else { return }
            
            videoSeekerSlider.maximumValue = Float(totalTime)
            
            var hours = 0
            
            var minutes = 0
            while totalTime >= 60 {
                minutes += 1
                totalTime -= 60
            }
            
            while minutes >= 60 {
                hours += 1
                minutes = minutes - 60
            }
            
            
        
            let seconds : Int = Int(totalTime)
            
            if hours > 0 {
                if minutes < 10 {
                    if seconds < 10 {
                        timeLabel.text = "\(hours):0\(minutes):0\(seconds)"
                    }else{
                        timeLabel.text = "\(hours):0\(minutes):\(seconds)"
                    }
                    
                }else{
                    if seconds < 10 {
                        timeLabel.text = "\(hours):\(minutes):0\(seconds)"
                    }else{
                        timeLabel.text = "\(hours):\(minutes):\(seconds)"
                        
                    }
                    
                }
            }else{
                if (seconds < 10) {
                    timeLabel.text = "\(minutes):0\(seconds)"
                }else{
                    timeLabel.text = "\(minutes):\(seconds)"
                    
                }
            }
            
          
          
            playerView.bringSubview(toFront: controlView)
          playerView.bringSubview(toFront: videoSeekerSlider)
        }
    }
    
    private var interval : CMTime?
    
    //this method gets called when player is rendering frames
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            if let videoPlayer = videoPlayer {
                
                addTotalVideoTime()
                
                let interval = CMTime(value: 1, timescale: 1)
                self.interval = interval
                
                videoPlayer.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
                    
                    let currentDuration = videoPlayer.currentTime()
                    var time = CMTimeGetSeconds(currentDuration)
                    
                    guard !(time.isNaN || time.isInfinite) else { return }
                    
                    self.videoSeekerSlider.value = Float(time)
                    
                    if time >= 60 {
                        var minutes = 0
                        while time > 60 {
                            minutes += 1
                            time -= 60
                        }
                        
                        if minutes >= 60 {
                            var hours = 0
                            while minutes > 60 {
                                hours += 1
                                minutes -= 60
                            }
                            
                            if minutes < 10 {
                                if time >= 10 {
                                    self.currentTimeLabel.text = "\(hours):0\(minutes):\(Int(time))"
                                }else{
                                    self.currentTimeLabel.text = "\(hours):0\(minutes):0\(Int(time))"
                                }
                                
                            }else{
                                if time >= 10 {
                                    self.currentTimeLabel.text = "\(hours):\(minutes):\(Int(time))"
                                }else{
                                    self.currentTimeLabel.text = "\(hours):\(minutes):0\(Int(time))"
                                }
                                
                            }
                            
                            
                        }else{
                            if time >= 10 {
                                
                                self.currentTimeLabel.text = "\(minutes):\(Int(time))"
                            }else{
                                
                                self.currentTimeLabel.text = "\(minutes):0\(Int(time))"
                            }
                        }
                        
                        
                    }
                    else if time >= 10 {
                        self.currentTimeLabel.text = "0:\(Int(time))"
                    }else{
                        self.currentTimeLabel.text = "0:0\(Int(time))"
                    }
                    
                    
                })
            }
        }
    }
    
    @IBAction func videoSliderChange(_ sender: UISlider) {
        
        if let videoPlayer = videoPlayer {
            let timeScale = videoPlayer.currentItem?.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(Float64(sender.value), timeScale!)
            videoPlayer.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            
        }
        
    }
    
    @IBAction func download(_ sender: UIButton) {
        
        let downloadInfo = DownloadInfo(image: videoImage, videoTitle: videoTitle,videoId : videoId,
            videoLink : videoUrl)
        
        if let data  = UserDefaults.standard.object(forKey: "downloads" ) as? Data {
            let downloadArray = NSKeyedUnarchiver.unarchiveObject(with: data) as!NSMutableArray
            
           downloadArray.add(downloadInfo)
            
            let newData = NSKeyedArchiver.archivedData(withRootObject: downloadArray)
            
            
               UserDefaults.standard.setValue(newData, forKey: "downloads")
            
            }
        
        else{
            let downloadArray = NSMutableArray()
            downloadArray.add(downloadInfo)
           
            let data = NSKeyedArchiver.archivedData(withRootObject: downloadArray)
            
            UserDefaults.standard.setValue(data, forKey: "downloads")
        }
      
     
    }
    
    
}
