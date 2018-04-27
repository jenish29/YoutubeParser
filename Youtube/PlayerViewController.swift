//
//  PlayerViewController.swift
//  Youtube
//
//  Created by pc on 7/12/17.
//  Copyright © 2017 pc. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let videoUrl = "https://r17---sn-p5qlsnzy.googlevideo.com/videoplayback?key=cms1&itag=18&mime=video/mp4&clen=20682791&gir=yes&id=o-AMaUAr02IbDoCHQYNtDE-IITdl5dg2twdjdyENnaxRSk&ratebypass=yes&ei=v69mWZmQGcHRDe37i8AJ&source=youtube&dur=225.326&requiressl=yes&ip=107.178.194.44&pl=24&expire=1499923487&ipbits=0&sparams=clen,dur,ei,expire,gir,id,ip,ipbits,itag,lmt,mime,mip,mm,mn,ms,mv,pl,ratebypass,requiressl,source&lmt=1478536522026297&signature=50510693F72EBEF5603B3628E4E813BBC1D8CA5D.452526505E62D4DF6FDD14848561E6C175560040&cms_redirect=yes&mip=208.39.175.75&mm=31&mn=sn-p5qlsnzy&ms=au&mt=1499901824&mv=m"
        
        let url = URL(string: videoUrl)!
    
        let data = NSData(contentsOf: url)
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        if let docDir = paths.first {
            let appFile = docDir.appending("/MyFile1.m4v")
            let movieUrl = URL(fileURLWithPath: appFile)
        
            do {
                try data?.write(to: movieUrl, options: .atomic)
                
                let player = AVPlayer(url: movieUrl)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.view.frame
                self.view.layer.addSublayer(playerLayer)
                
                DispatchQueue.main.async {
                         player.play()
                }
           
            }catch{
                print("error occured")
            }
        }
        else{
            print("error")
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
