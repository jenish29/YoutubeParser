//
//  PlayerAvPlayer.swift
//  Youtube
//
//  Created by pc on 7/28/17.
//  Copyright © 2017 pc. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerAvPlayer: AVPlayer,VideoSliderChangeDelegate {
    private var playerLayer : AVPlayerLayer!
    private var superView : Player!
    
    func play(playerLayer : AVPlayerLayer, superView : Player) {
    
        //assiging playerLayer
        self.playerLayer = playerLayer
        self.superView = superView
        
        //assining videoSliderDelegate so this classes method will be called
        self.superView.delegate = self
        self.superView.videoSlider.delegate = self
        
        setUpPlayer()
            
        //calling super play function to play the video
        play()

        superView.bringSubview(toFront: superView.controllerView)
        UIApplication.shared.isStatusBarHidden = true

    }
    
    // setting time for player
    private func setUpPlayer() {
        addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
    }
    
    func removeObs() {
        added = false
        removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
    }
    
    private var added = false
    
    //this method gets called when player is rendering frames
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            //adding total time to seeker
            let time = CMTimeGetSeconds((currentItem?.duration)!)
            
            //making sure valid values
            guard !(time.isNaN || time.isInfinite) else { return }

            superView.videoSlider.maximumValue = Float(time)
            superView.durationLabel.text = generateTime(time: Int(CMTimeGetSeconds((self.currentItem?.duration)!)))

            let interval = CMTime(value: 1, timescale: 1)
            
            if !added {
                added = true
                
                //time observer
                addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (_) in
                    //time label
                    let currentTime = CMTimeGetSeconds(self.currentTime())
                    
                    //making sure valid values
                    guard !(currentTime.isNaN || currentTime.isInfinite) else { return }
                    
                    self.superView.timeLabel.text = self.generateTime(time: Int(currentTime))
    
                   //advancing the slider
                    self.superView.videoSlider.setValue(Float(currentTime), animated: true)

                })
            }
        }
    }
    
    //generating time in formate
    private func generateTime(time:Int) -> String {
        let seconds = time % 60;
        let minutes = (time / 60) % 60;
        let hours = time / 3600;
    
        if time > 3600 {
            return String.localizedStringWithFormat("%02d:%02d:%02d",hours,minutes,seconds)
        }else if minutes > 9 {
            return String.localizedStringWithFormat("%02d:%02d",minutes,seconds)
        }else {
            return String.localizedStringWithFormat("%01d:%02d",minutes,seconds)
        }
    }

    private var seekerChanging = false
    private var stillTouching = false
    
    // this function will be called when videoSliderChanges
    func videoSliderChange() {
        let timeScale = currentItem?.asset.duration.timescale
        let time = CMTimeMakeWithSeconds(Float64(superView.videoSlider.value), timeScale!)
        seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) { (_) in
            if !self.stillTouching {
                self.playImmediately(atRate: 1)
            }
        }
    }
    
    func videoSlideTouch() {
        stillTouching = true
        pause()
    }
    
    func videoSlideTouchEnded() {
        play()
        stillTouching = false
    }
    
    func touchesCancelled() {
        self.playImmediately(atRate: 1)
        stillTouching = false
    }
    
    func valueChange(sender: customSlider) {
        pause()
        videoSliderChange()
    }
    
    func panGestureBegan() {
        if isPlaying{
            stillTouching = true
            pause()
        }
    }
    
    func panGestureEnded() {
        play()
        stillTouching = false
    }
    
    func pauseVideo() {
        if(isPlaying) {
            pause()
        }else{
            playImmediately(atRate: 1)
        }
     
    }
}

