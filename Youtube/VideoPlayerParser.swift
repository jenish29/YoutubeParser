//
//  YoutubeParser.swift
//  Youtube
//
//  Created by pc on 7/12/17.
//  Copyright © 2017 pc. All rights reserved.
//

import Foundation

class VideoPlayerParser {
    private var urlString = "https://www.ytpak.com/watch?v="
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
                    self.videoUrl(data: st as String)
                    completionHandler()
                }
            }
            catch {}
        }
    }
    
    func videoUrl(data:String) {
        let parser = "a href=\"https[\\s|\\S]*?=mp4"
        let videoUrl = matchesForRegexInText(regex: parser, text: data)
        
        if videoUrl.count < 0 {return}
        
        var url = videoUrl[0]

        url = url.replacingOccurrences(of: "a href=\"", with: "")
      
        
        let dic = NSMutableDictionary()
        dic.setValue(url, forKey: "url")
        dataArray.append(dic)
        
    }
    func getData() -> NSArray {
        return dataArray as NSArray
    }
    
    


    
    
}
