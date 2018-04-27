
//
//  HomeViewController.swift
//  Youtube
//
//  Created by pc on 7/12/17.
//  Copyright © 2017 pc. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

extension UIViewController : SearchViewDelegate {
    func searchVideo(_: String) {
        
    }
}

class HomeViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,BottomBarDelegate{
    
    private var videoData : [NSDictionary] = []
    private let apiKey = "AIzaSyBTnPDfqxiXpzf6moCsBdweDiys89ZFhMs"
    private var downloadController : DownloadViewController!

    @IBOutlet var bottomBarView: BottomBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        //initializing variables
        bottomBarView.delegate = self
        self.downloadController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "downloader") as! DownloadViewController
        
     
    }
 
    
    @IBOutlet private var searchView: UIView!
    @IBOutlet private var searchTextField: UITextField!
    
    //brings the search bar up when search button is pressed
    @IBAction func search(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) { 
            if self.searchView.alpha == 1 {
                self.searchView.alpha = 0
                self.searchTextField.resignFirstResponder()
            }else{
                self.searchTextField.becomeFirstResponder()
                self.searchView.alpha = 1
            }
        }
    }
    
    //main tableview
    @IBOutlet private var videosTableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! YoutubeCell
        cell.videoImage.image = nil
        
        if videoData.count > 0{
            let data = videoData[indexPath.row]
            
            let videoTitle = data.value(forKey: "videoTitle") as! String
            cell.videoTitle.text = videoTitle
            
            let videoUser = data.value(forKey: "videoUser") as! String
            cell.videoUser.text = videoUser
            
            let upDate = data.value(forKey: "date") as! String
            cell.uploadDate.text = upDate
            
            let scribers = data.value(forKey: "view") as! String
            cell.views.text = scribers
            
            let videoUrl = data.value(forKey: "imageUrl") as! String
            
            getImage(url: videoUrl, completionHandler: { (data, err) in
                if err == nil {
                    if let data = data, let _ = tableView.cellForRow(at: indexPath) {
                        let image = UIImage(data: data)
                        cell.videoImage.image = image
                        cell.setNeedsLayout()
                        
                        
                    }else{
                  
                    }
                }
            })
        }
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! YoutubeCell
        let data = videoData[indexPath.row]
        let id = data.value(forKey: "id")
        
        let parser = VideoPlayerParser()
       NotificationCenter.default.post(name: NSNotification.Name("open"), object: self)
  
        parser.parse(string: id! as! String) {
            let urlString = (parser.getData()[0] as! NSMutableDictionary).value(forKey: "url") as! String
            
            let videoData = videoInfo(videoId: id! as! String, videoUrl: urlString,videoImage : cell.videoImage.image,videoTitle : cell.videoTitle.text)
            let hashAbleArray = ["videoData" : videoData]
            NotificationCenter.default.post(name: NSNotification.Name("playVideo"), object: nil, userInfo: hashAbleArray)
        }
    

    }


    public func searchForVideos(searchString : String) {
        if searchTextField.text == "" {
            return
        }
        
        var searchParam = searchString
        searchParam = searchParam.replacingOccurrences(of: " ", with: "%20")
        let parser = YoutubeParser()
        
        parser.parse(string: searchParam) { 
            let videoArr = parser.getData()
            self.videoData = videoArr as! [NSDictionary]
            self.videosTableView.reloadData()
        }
        
    }

    func tabClicked() {
        UIView.animate(withDuration: 1) {
            self.addChildViewController(self.downloadController)
            self.downloadController.didMove(toParentViewController: self)
            self.downloadController.view.frame = self.view.frame
            //self.downloadController.addDownloads()
            self.addChildViewController(self.downloadController)
            self.view.addSubview(self.downloadController.view)
        }
    }

    override func searchVideo(_ searchString: String){
        searchForVideos(searchString: searchString)
    }

}

//custom tableview Cell
class YoutubeCell : UITableViewCell {
    @IBOutlet var videoImage: UIImageView!
    @IBOutlet var videoTitle: UILabel!
    
    @IBOutlet var videoUser: UILabel!
    @IBOutlet var uploadDate: UILabel!
    @IBOutlet var views: UILabel!

    var player : AVPlayer? = nil
    var playerLayer : AVPlayerLayer? = nil
    
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

struct videoInfo {
    let videoId : String?
    let videoUrl : String?
    let videoImage : UIImage?
    let videoTitle : String?
    
    init(videoId:String,videoUrl:String, videoImage : UIImage?,videoTitle : String?) {
        self.videoId = videoId
        self.videoUrl = videoUrl
        self.videoImage = videoImage
        self.videoTitle = videoTitle
    }
}
