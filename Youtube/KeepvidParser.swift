//
//  KeepvidParser.swift
//  Youtube
//
//  Created by pc on 7/14/17.
//  Copyright © 2017 pc. All rights reserved.
//

import Foundation

class KeepvidParser {
    
    private var urlString = "http://keepvid.com/?url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3D"
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
    
        let parser = "googlevideo[\\s|\\S]*?\""
        let parsedData = matchesForRegexInText(regex: parser, text: data)

        if parsedData.count > 0 {
            var url = parsedData[1]
            url = url.replacingOccurrences(of: "\"", with: "")
            url = "https://redirector." + url
            
            let dic = NSMutableDictionary()
            dic.setValue(url, forKey: "url")
            dataArray.append(dic)
        }
      
    }
    func getData() -> NSArray {
        return dataArray as NSArray
    }

}
