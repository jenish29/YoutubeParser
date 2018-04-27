//
//  Player.swift
//  Youtube
//
//  Created by pc on 7/28/17.
//  Copyright © 2017 pc. All rights reserved.
//

import UIKit

class Player: UIView {
    
    var videoSlider : customSlider!
    var timeLabel : UILabel!
    var durationLabel : UILabel!
    
    var delegate : VideoSliderChangeDelegate?
    var controllerView : UIView!
    var bottomContraintVideoSlider : NSLayoutConstraint!
    
    func sliderChange (_ sender: Any) {
        delegate?.videoSliderChange()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let view = UIView()
        view.backgroundColor = UIColor.clear
        addSubview(view)
        addConstraintsWithFormat("H:|[v0]|", views: view)
        addConstraintsWithFormat("V:[v0(50)]|", views: view)
        self.controllerView = view
        
        //adding seeker slider
        let slider = customSlider()

        view.addSubview(slider)
        view.addConstraintsWithFormat("H:|-15-[v0]-15-|", views: slider)
        view.addConstraintsWithFormat("V:[v0(25)]", views: slider)
        videoSlider = slider
    
        videoSlider.setThumbImage(videoSlider.generateHandleImage(with: .red), for: .normal)
        
        //bottom constaint
        bottomContraintVideoSlider = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: slider, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomContraintVideoSlider)
        
        //adding pan gesture
        let panGesture = UIPanGestureRecognizer(target: slider, action: #selector(slider.videoCame))
        slider.addGestureRecognizer(panGesture)
        slider.panGesture = panGesture

        //time label
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: 20)
        label.textColor = UIColor.white
        view.addSubview(label)
        view.addConstraintsWithFormat("H:|-20-[v0(150)]", views: label)
        view.addConstraintsWithFormat("V:[v0(15)]-10-[v1]", views: label,slider)
        self.timeLabel = label
        
        //adding duartion label
        let durationLbael = UILabel()
        durationLbael.font = UIFont.systemFont(ofSize: 20, weight: 20)
        durationLbael.textColor = UIColor.white
        durationLbael.textAlignment = .right
        view.addSubview(durationLbael)
        view.addConstraintsWithFormat("H:[v0(150)]-20-|", views: durationLbael)
        view.addConstraintsWithFormat("V:[v0(15)]-10-[v1]", views: durationLbael,slider)
        self.durationLabel = durationLbael
     
        //pausevideoGestrue
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pauseVid)))
 
    }
    
    //selector called to pauseVideo 
    func pauseVid(){
        delegate?.pauseVideo()
    }
}

protocol VideoSliderChangeDelegate  {
    func videoSliderChange()
    func videoSlideTouch()
    func videoSlideTouchEnded()
    func touchesCancelled()
    func valueChange(sender : customSlider)
    func panGestureEnded()
    func panGestureBegan()
    func pauseVideo()
}

class customSlider : UISlider {
    
    var delegate : VideoSliderChangeDelegate?
    var image : UIImage!
    var panGesture : UIPanGestureRecognizer!
    
    //this method will be called when pan gesture is recognized
    private var val = 0
    func videoCame(_ sender: UIPanGestureRecognizer) {

        //pausing the video
        if sender.state == .began || (sender.state == .changed) { delegate?.panGestureBegan() }
  
        //the location of current thumnail
        let _ = value / maximumValue * Float(bounds.width)
        //location of touch
        let locationOfTouch = Float(sender.location(in: self).x)

        //if sender.state == .began {value = sender.direction == .right ? value + 1 : value - 1; val = val + 1}
        
        //getting swipe direction
        let direction = sender.direction
        if direction == Direction.up || direction == Direction.down { return }
        
        //forward video
        if direction == Direction.right { value =  locationOfTouch * maximumValue / Float(bounds.width)}
        else if direction == Direction.left { value = locationOfTouch * maximumValue / Float(bounds.width)}

        //setting value of slider
        self.setValue(value, animated: false)
        delegate?.valueChange(sender: self) // forwarding the video
    
        //pan gesture ended so play the video
        if sender.state == .ended  {delegate?.panGestureEnded()}
    
    }
    
    //creates image for the ThumbPic
     func generateHandleImage(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: self.bounds.size.height - 30, height: self.bounds.size.height
        )

        let image = UIGraphicsImageRenderer(size: rect.size).image { (imageContext) in
            imageContext.cgContext.setFillColor(color.cgColor)
            imageContext.cgContext.fill(rect.insetBy(dx: 0, dy: 10
            ))
        }
        
        self.image = image
        return self.image
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        videoCame(panGesture)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        delegate?.videoSlideTouch()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        delegate?.videoSlideTouchEnded()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
       delegate?.touchesCancelled()
    }
}
