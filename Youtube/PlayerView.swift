//
//  PlayerView.swift
//  Youtube
//
//  Created by pc on 7/28/17.
//  Copyright © 2017 pc. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class PlayerView: UIView, UIGestureRecognizerDelegate{
    
    //delegate
    var delegate : PlayerVCDelegate?
    
    func customizeView() {
        //hiding the statusBar
        UIApplication.shared.isStatusBarHidden = true
        
        //adding videoView
        let view = Player()
        view.backgroundColor = UIColor.black
        addSubview(view)
        view.frame = CGRect(x: 0, y: 0, width:UIScreen.main.bounds.size.width,height: 233)
        view.awakeFromNib()
        self.videoView = view
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:))))
        
        let button = UIButton()
        button.setTitle("Download", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.blue, for: .highlighted)
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(download), for: .touchUpInside)
        
        addSubview(button)
        button.frame = CGRect(x: view.frame.size.width - 110, y: view.frame.size.height + 10, width: 100, height: 50)
        
        //adding notification listner
        NotificationCenter.default.addObserver(self, selector: #selector(self.tapPlayView), name: NSNotification.Name("open"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupPlayer), name: NSNotification.Name("playVideo"), object: nil)
        
    }
    
    //function to downloadVideo
    func download(_ sender : UIButton){
        if videoInfo != nil {
            let videoUrl = videoInfo?.videoUrl
            let videoId = videoInfo?.videoId
            let videoImage = videoInfo?.videoImage!
            let videoTitle = videoInfo?.videoTitle!
            
            let downloadInfo = DownloadInfo(image: videoImage!, videoTitle: videoTitle!, videoId: videoId!, videoLink: videoUrl!)
            
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
    
    //video id
    private var videoInfo : videoInfo?
    var videoPlayer : PlayerAvPlayer?
    var videoPlayerLayer : AVPlayerLayer?
    // main videoView
    var videoView: Player!
    
    //setting up videoPlayer
    func setupPlayer(_ notification : NSNotification) {
        videoInfo = (notification.userInfo?["videoData"] as! videoInfo)
        
        //this is to check if the video has been downloaded if so play the saved video
        let documentsUrl : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let destinationUrl = documentsUrl.appendingPathComponent(videoInfo!.videoId!+".mp4")
        
        let isVideoSaved = FileManager.default.fileExists(atPath: destinationUrl.path)
        
        stopVideo()
        
        var player = PlayerAvPlayer()
        
        //if video is saved then play that otherwise play from video url
        if isVideoSaved {
            player = PlayerAvPlayer(url: destinationUrl)
        }else{
            let videoUrl = URL(string: (self.videoInfo?.videoUrl)!)
            player = PlayerAvPlayer(url: videoUrl!)
        }
        
        //creating playerLayer for avPlayer and adding it to videoView
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoView.frame
        self.videoView.layer.addSublayer(playerLayer)
        
        //stop waiting and play immidietly
        player.automaticallyWaitsToMinimizeStalling = false
        
        //starting the video
        player.play(playerLayer: playerLayer,superView: self.videoView)
        
        self.videoPlayer = player
        self.videoPlayerLayer = playerLayer
        
    }
    
    //function when tap gesture regonized in videoView
    func tapPlayView() {
        print("came here")
        //making fullscreen
        self.state = .fullScreen
        self.delegate?.didMaximize()
        self.videoPlayerLayer?.frame = self.videoView.frame
        self.backgroundColor = UIColor.white.withAlphaComponent(1)
        self.animate {
        }
        stopVideo()
    }
    
    func stopVideo() {
        //stopping previous video
        if self.videoPlayer != nil {
            self.videoPlayer?.pause()
            self.videoPlayer?.removeObs()
            self.videoPlayer?.replaceCurrentItem(with: nil)
            
            self.videoPlayerLayer = nil
            self.videoPlayer = nil
            
            videoView.timeLabel.text = "0:00"
            videoView.durationLabel.text = "0:00"
            videoView.videoSlider.setValue(0, animated: false)
        }
    }
    
    //direction of pan
    var direction = Direction.none
    var state = stateOfVC.fullScreen    //current state of the View
    
    //pan gesture recgonizer
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        
        //if device is rotated we dont want
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            return
        }
        
        if sender.direction != Direction.down && sender.direction != Direction.up && sender.state == .began {return}
        
        //final state the view eneded
        var finalState = stateOfVC.fullScreen
        
        switch self.state {
        case .fullScreen:
            let factor = (abs(sender.translation(in: nil).y)/UIScreen.main.bounds.height)
            self.changeValues(scaleFactor: factor, positive: false)
            self.delegate?.swipeTOminimize(translation: factor, toState: .minimized)
            finalState = .minimized
        case .minimized:
            if sender.direction == Direction.left {
                finalState = .hidden
                let factor: CGFloat = sender.translation(in: nil).x
                self.delegate?.swipeTOminimize(translation: factor, toState: .hidden)
                
            }else {
                finalState = .fullScreen
                let factor = 1 - (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
                self.changeValues(scaleFactor: factor, positive: false)
                self.delegate?.swipeTOminimize(translation: factor, toState: .fullScreen)
            }
            
        default: break
            
        }
        
        if sender.state == .ended {
            if sender.direction == Direction.down {
                finalState = .minimized
            }else if sender.direction == Direction.up {
                finalState = .fullScreen
            }else {
                finalState = .hidden
                videoPlayer?.pauseVideo()
            }
            
            self.state = finalState
            animate {}
            self.delegate?.didEndedSwipe(toState: self.state)
        }
        
        //pan gesture ended
    }
    
    //this function will be called for to change the scale and translate the VideoView accordingly
    func changeValues(scaleFactor: CGFloat, positive: Bool) {
        
        let scaleVal = 1 - 0.5 * scaleFactor
        
        var translationVal = self.videoView.bounds.width / 4 * scaleFactor
        translationVal = positive ? translationVal : -translationVal
        
        let scale = CGAffineTransform.init(scaleX: scaleVal, y: scaleVal)
        let trasform = scale.concatenating(CGAffineTransform.init(translationX: translationVal, y: translationVal))
        self.videoView.transform = trasform
    }
    
    func animate(completionHandler : @escaping () -> Swift.Void)  {
        switch self.state {
        case .fullScreen:
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundColor = UIColor.white.withAlphaComponent(1)
                self.videoView.transform = CGAffineTransform.identity
                UIApplication.shared.isStatusBarHidden = true
                
            }, completion: { (_) in
                completionHandler()
            })
            
        case .minimized:
            UIView.animate(withDuration: 0.3, animations: {
                UIApplication.shared.isStatusBarHidden = false
                self.backgroundColor = UIColor.white.withAlphaComponent(0)
                let scale = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
                let trasform = scale.concatenating(CGAffineTransform.init(translationX: -self.videoView.bounds.width/4, y: -self.videoView.bounds.height/4))
                self.videoView.transform = trasform
                
            }, completion: { (_) in
                completionHandler()
            })
            
        default: break
        }
    }
    
    //function called when view starts
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame = UIScreen.main.bounds
        
        //calling customView to initialize required values
        customizeView()
    }
}

protocol PlayerVCDelegate {
    func didMinimize()
    func didMaximize()
    func swipeTOminimize(translation: CGFloat, toState: stateOfVC)
    func didEndedSwipe(toState: stateOfVC)
}

enum stateOfVC {
    case minimized
    case fullScreen
    case hidden
}

public enum Direction: Int {
    case up,
    down,
    left,
    right,
    none
    
    public var isX: Bool {
        return self == .left || self == .right
    }
    
    public var isY: Bool {
        return !isX
    }
}

extension UIPanGestureRecognizer{
    var direction: Direction? {
        let velocity = self.velocity(in: view)
        let vertical = fabs(velocity.y) > fabs(velocity.x)
        switch (vertical, velocity.x, velocity.y) {
        case (true, _, let y):
            return y < 0 ? .up : .down
            
        case (false, let x, _):
            return x > 0 ? .right : .left
        }
    }
}


