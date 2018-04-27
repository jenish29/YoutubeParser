//
//  has403Code.swift
//  Youtube
//
//  Created by Jenish on 8/1/17.
//  Copyright © 2017 pc. All rights reserved.
//

import Foundation
import UIKit

class Has403:UIViewController,URLSessionDataDelegate {

    private var completion : ((Bool) -> Void)!
    private var completionString : ((String) -> Void)!
    var viewController : DownloadViewController!

    //checking if url has 403 status cod
    func parse(viewController : DownloadViewController? = nil,urlString: String,completionHandler: @escaping (Bool) -> Swift.Void){
        self.viewController = viewController
        let url = URL(string: urlString)
        self.completion = completionHandler
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request)
        task.resume()
    }

    func parseString(viewController : DownloadViewController? = nil,urlString: String,completionHandler: @escaping (String) -> Swift.Void){
        self.viewController = viewController
        let url = URL(string: urlString)
        self.completionString = completionHandler
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request)
        task.resume()
    }

    //delegate method invoked when urlresponse recived
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        let respons = response as! HTTPURLResponse

        dataTask.cancel()
        session.invalidateAndCancel()

        if completion != nil {
            switch respons.statusCode {
            case 403:
                completion(true)
            default:
                completion(false)
            }
        }

        
    }
    
    
    
    
}
