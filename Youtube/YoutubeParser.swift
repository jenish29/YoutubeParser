//
//  YoutubeParser.swift
//  Youtube
//
//  Created by pc on 7/12/17.
//  Copyright © 2017 pc. All rights reserved.
//

import Foundation

class YoutubeParser {
    private var urlString = "https://www.youtube.com/results?search_query="
    private var dataArray : [NSMutableDictionary] = []
    
    func matchesForRegexInText(regex: String, text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                                        options: [], range: NSMakeRange(0, nsString.length))
            let maps =  results.map { nsString.substring(with: $0.range)}
            return maps
        } catch {
            
            return []
        }
    }
    
    func parse(string: String,completionHandler: @escaping () -> Swift.Void){
        let url = NSURL(string: (urlString + string))
    
        DispatchQueue.global().async {
            do {
                let st = try NSString.init(contentsOf: url! as URL, encoding: String.Encoding.ascii.rawValue)
                DispatchQueue.main.async {
                    self.videos(data: st as String)
                    completionHandler()
                }
            }
            catch {}
        }
    }
    func getData() -> NSArray {
        return dataArray as NSArray
    }
    
    func videos(data:String) {
      
        var parser = "item-section[\\s|\\S]*?id=\"search-secondary-col-contents"
        var videoData = matchesForRegexInText(regex: parser, text: data)
        
        //parsing more
        if videoData.count > 0{
            parser = "yt-lockup-dismissable yt-uix-tile[\\s|\\S]*?</div></li"
            
            videoData = matchesForRegexInText(regex: parser, text: videoData[0])
            
            if videoData.count > 0 {
                for video in videoData {
                    let dicVal = NSMutableDictionary()
                 
                    let imageUrl = getVideoUrl(video: video)
                 
                    dicVal.setValue(imageUrl, forKey: "imageUrl")
                    
                    let imageTitle = getVideoTitle(video: video)
                    dicVal.setValue(imageTitle, forKey: "videoTitle")
                   
                    let videoUser = getVideoUser(video: video)
                    dicVal.setValue(videoUser, forKey: "videoUser")
                    
                    let (date,view) = getDateAndViews(video: video)
                    dicVal.setValue(view, forKey: "view")
                    dicVal.setValue(date, forKey: "date")
              
                    let dataConextId = getDataConentId(video: video)
                    dicVal.setValue(dataConextId, forKey: "id")
                    
                    dataArray.append(dicVal)
                }
            }
        }
    }
    
    func getVideoUrl(video:String) -> String {
        
        let imageUrlParser = "img[\\s|\\S]*?\\?"
        let imageUrl = matchesForRegexInText(regex: imageUrlParser, text: video)
        
        if imageUrl.count > 0 {
            let imageUrArr = imageUrl[0]
            let parser = "https.*\\?"
            let imageUr = matchesForRegexInText(regex: parser, text: imageUrArr)
            if imageUr.count == 0 {return ""}
       
            return imageUr[0]
        }
        return ""
    }
    
    func getVideoTitle(video:String) -> String{
        
        //getting Videotitle
        let imageTitleParser = "ltr[\\s|\\S]*?</a"
        var imageTitleArr = matchesForRegexInText(regex: imageTitleParser, text: video)
        if imageTitleArr.count == 0 {return ""}
        
        var imageTitle = imageTitleArr[0]
        imageTitle = imageTitle.replacingOccurrences(of: "ltr\">", with: "")
        imageTitle = imageTitle.replacingOccurrences(of: "</a", with: "")
        imageTitle = imageTitle.replacingOccurrences(of: "&#39;", with: "'")
        return imageTitle
    }
    
    func getVideoUser(video:String) -> String {
 
        //getting videoUser
        let videoUserParser = "yt-lockup-byline[\\s|\\S]*?</a"
        var videoUserArr = matchesForRegexInText(regex: videoUserParser, text: video)
        
        if videoUserArr.count == 0 {return ""}
        
        let videoUser = videoUserArr[0]
        
  
        var parser = "itct[\\s|\\S]*?<"
        videoUserArr = matchesForRegexInText(regex: parser, text: videoUser)
        if videoUserArr.count == 0 {return ""}
      
        
        parser = ">[\\s|\\S]*?<"
        videoUserArr = matchesForRegexInText(regex: parser, text: videoUserArr[0])
        
        if videoUserArr.count == 0 {return ""}
        
        var user = videoUserArr[0]
        
        user = user.replacingOccurrences(of: ">", with: "")
        user = user.replacingOccurrences(of: "<", with: "")
        
        return user
   
 
    }
    
    func getDateAndViews(video:String) -> (String,String) {
    
        var parser = "<li>\\d+[\\s|\\S]*?ago"
        
        let times = matchesForRegexInText(regex: parser, text: video)
        if times.count == 0 {return ("","")}
        var time = times[0]
        time = time.replacingOccurrences(of: "<li>", with: "")
        
        parser = "<li>\\d+[\\s|\\S]*?views"
        let views = matchesForRegexInText(regex: parser, text: video)
        if views.count == 0 {return (time,"")}
        
        var view = views[0]
        view = view.replacingOccurrences(of: time, with: "")
        while view.contains("<li>") {
            view = view.replacingOccurrences(of: "<li>", with: "")
            view = view.replacingOccurrences(of: "</li>", with: "")
        }
        
        return(time,view)
        
    }
    
    func getDataConentId (video:String) -> String {
        let parser = "href=\"/watch?[\\s|\\S]*?cla"
        let idArr = matchesForRegexInText(regex: parser, text: video)
        
        if idArr.count == 0 {return ""}
        
        var id = idArr[0]
        id  = id.replacingOccurrences(of: "href=\"/watch?v=", with: "")
        id = id.replacingOccurrences(of: "\" cla", with: "")
        
      
        
        return id
        
    }
    
    
}
