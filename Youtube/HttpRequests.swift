
import Foundation

enum Urls : String {
    case search = "http://www.a2zoffer.com/jenish2.php?search="
}


func getData(url : String,  completionHandler:  @escaping (Data?,String, Error?) -> Swift.Void) {
    
    if let url = NSURL(string: url) {
        //creates url request
        var request = URLRequest(url: url as URL)
        request.httpMethod = "GET"
        
        // try catch for json serialization
        do{
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response : URLResponse?, err: Error?) in
                
                DispatchQueue.main.sync {
                    var responseString : NSString = "";
                    if(err == nil){
                        
                        responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                        responseString = responseString.trimmingCharacters(in: .newlines) as NSString
                        
                    }
                    
                    completionHandler(data,responseString as String, err)
                }
                
                
            })
            task.resume()
            
        }
    }else{
        completionHandler(nil,"",nil)
    }
    
    
}

func getImage(url:String,completionHandler: @escaping (Data?,Error?) -> Swift.Void) {
    if let url = NSURL(string: url) {
        
        let request = URLRequest(url: url as URL)
        let session = URLSession(configuration: .default)
        
        let downloadTask = session.dataTask(with: request, completionHandler: { (data, response, err) in
            DispatchQueue.main.sync {
                completionHandler(data,err)
            }
            
        })
        
        downloadTask.resume()
    }
}







