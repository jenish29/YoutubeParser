//
//  DownloadInfo.swift
//  Youtube
//
//  Created by Jenish on 7/21/17.
//  Copyright © 2017 pc. All rights reserved.
//

import Foundation
import UIKit

class DownloadInfo: NSObject, NSCoding {

    var image : UIImage!
    var videoTitle : String!
    var videoId : String!
    var videoLink : String!
    var isDownloadComplete : Bool!
    var downloadLocation : URL!
    var currentlyGettingNew : Bool!

    init(image : UIImage, videoTitle : String, videoId : String, videoLink : String) {
        self.image = image
        self.videoTitle = videoTitle
        self.videoId = videoId
        self.videoLink = videoLink
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(image, forKey: "image")
        aCoder.encode(videoTitle,forKey: "videoTitle")
        aCoder.encode(videoId,forKey: "videoId")
        aCoder.encode(videoLink,forKey: "videoLink")
        aCoder.encode(isDownloadComplete,forKey: "isDownloaded?")
        aCoder.encode(downloadLocation,forKey: "downloadLocation")
        aCoder.encode(currentlyGettingNew,forKey: "currentlyGetting")
    }

    override init() {
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        image = aDecoder.decodeObject(forKey: "image") as? UIImage
        videoTitle = aDecoder.decodeObject(forKey: "videoTitle") as? String
        videoId = aDecoder.decodeObject(forKey: "videoId") as? String
        videoLink = aDecoder.decodeObject(forKey: "videoLink") as? String
        isDownloadComplete = aDecoder.decodeObject(forKey: "isDownloaded?") as? Bool
        downloadLocation = aDecoder.decodeObject(forKey: "downloadLocation") as? URL
        currentlyGettingNew = aDecoder.decodeObject(forKey: "currentlyGetting") as? Bool
    }
    
    
}

