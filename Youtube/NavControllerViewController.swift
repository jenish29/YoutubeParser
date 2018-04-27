//
//  NavControllerViewController.swift
//  Youtube
//
//  Created by pc on 7/28/17.
//  Copyright © 2017 pc. All rights reserved.
//

import UIKit

class NavControllerViewController: UINavigationController, PlayerVCDelegate {
    
    @IBOutlet var playerView: PlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //init playerView
        self.playerView.frame = CGRect.init(origin: self.hiddenOrigin, size: UIScreen.main.bounds.size)
        self.playerView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(orienTationChange), name:  NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        originalFrame = playerView.videoView.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(self.playerView)
        }
    }
    
    //hidden origin to hide playerView
    let hiddenOrigin: CGPoint = {
        let y = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 9 / 32) - 10
        let x = UIScreen.main.bounds.width
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    
    let minimizedOrigin: CGPoint = {
        let x = UIScreen.main.bounds.width/2 - 10
        let y = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 9 / 32) - 10
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    
    //origin of the view so it animates to here
    let fullScreenOrigin = CGPoint.init(x: 0, y: 0)


    //playerView delegateMethods
    func didMaximize() {
        self.animatePlayView(toState: .fullScreen)
    }
    
    func didMinimize() {
        
    }
    
    func didEndedSwipe(toState: stateOfVC) {
        self.animatePlayView(toState: toState)
    }
    
    func swipeTOminimize(translation: CGFloat, toState: stateOfVC) {
        switch toState {
        case .fullScreen:
            self.playerView.frame.origin = self.positionDuringSwipe(scaleFactor: translation)
        case .hidden:
            self.playerView.frame.origin.x = UIScreen.main.bounds.width/2 - abs(translation) - 10
        case .minimized:
            self.playerView.frame.origin = self.positionDuringSwipe(scaleFactor: translation)
        }
    }
    
    func positionDuringSwipe(scaleFactor: CGFloat) -> CGPoint {
        let width = UIScreen.main.bounds.width * 0.5 * scaleFactor
        let height = width * 9 / 16
        let x = (UIScreen.main.bounds.width - 10) * scaleFactor - width
        let y = (UIScreen.main.bounds.height - 10) * scaleFactor - height
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }
    
    
    //function to animate Playerview
    func animatePlayView(toState: stateOfVC) {
        switch toState {
        case .fullScreen:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [.beginFromCurrentState], animations: {
                self.playerView.frame.origin = self.fullScreenOrigin
            })
        case .minimized:
            UIView.animate(withDuration: 0.3, animations: {
                self.playerView.frame.origin = self.minimizedOrigin
            })
        case .hidden:
            UIView.animate(withDuration: 0.3, animations: {
                self.playerView.frame.origin = self.hiddenOrigin
            })
        }
    }
    
    //original frame
    private var originalFrame = CGRect(x: 0, y: 0, width: 414, height: 233)
    // previouse uidevice location
    private var previousRotation = UIDeviceOrientation.unknown
    
    func orienTationChange() {
        if UIDevice.current.orientation == .faceUp  || UIDevice.current.orientation == UIDeviceOrientation.faceDown
           || UIDevice.current.orientation.isFlat  || UIDevice.current.orientation == .unknown  {
            return
        }

        if let window = UIApplication.shared.keyWindow,
            let _ = playerView.videoPlayer {
            
           if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight ||
              UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft{
            
                //chaging the frame so becomes fullScreen
                playerView.frame = window.frame
                playerView.videoView.frame = window.frame
                playerView.videoPlayerLayer?.frame = window.frame
            
                //updating slider Bottom constraint
                playerView.videoView.bottomContraintVideoSlider.constant = 10
                previousRotation = .landscapeLeft
            
            }else if UIDevice.current.orientation == UIDeviceOrientation.portrait && previousRotation == .landscapeRight || previousRotation == .landscapeLeft {
            
                //changing the frame so becomes full screen
                playerView.frame = window.frame
                playerView.videoView.frame = originalFrame
                playerView.videoPlayerLayer?.frame = originalFrame

                //updating slider bottom constraint
                playerView.videoView.bottomContraintVideoSlider.constant = 0
                previousRotation = .unknown
            }
         
    
        }
        
    }

}
