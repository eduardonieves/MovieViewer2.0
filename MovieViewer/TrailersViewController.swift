//
//  TrailersViewController.swift
//  MovieViewer
//
//  Created by Eduardo Nieves on 2/2/16.
//  Copyright © 2016 Jesus Acevedo. All rights reserved.
//

import UIKit
import SwiftSpinner

class TrailersViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var trailerErrorView: UIView!
   
    var trailer: [NSDictionary]!
    var id: String!
    var imageUrl: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    
        
        //request
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"http://api.themoviedb.org/3/movie/\(id)/videos?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let trailer = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        trailer, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary["results"])")
                            self.trailer = responseDictionary["results"] as? [NSDictionary]
                           self.webView.reload()
                            
                            if self.trailer.isEmpty{
                                self.trailerErrorView.hidden = false
                                self.webView.hidden = true
                            }
                            else{
                                let key = self.trailer[0]["key"] as! String
                            let trailerURL = NSURL(string:"https://www.youtube.com/watch?v=\(key)")
                            print(key)
                            let request2 = NSURLRequest(URL: trailerURL!)
                            self.webView.loadRequest(request2)
                            }
                    }
                }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
