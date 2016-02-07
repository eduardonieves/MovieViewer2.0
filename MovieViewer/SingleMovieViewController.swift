//
//  SingleMovieViewController.swift
//  MovieViewer
//
//  Created by Eduardo Nieves on 1/25/16.
//  Copyright © 2016 Eduardo Nieves. All rights reserved.
//

import UIKit

class SingleMovieViewController: UIViewController {

 
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var realeaseLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
     var movie: NSDictionary!    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.height, height: infoView.frame.origin.y + infoView.frame.height)
        
        
        let title = movie["title"] as! String
        titleLabel.text = title
        
        let overview = movie["overview"] as! String
        overviewLabel.text = overview as String
        overviewLabel.sizeToFit()
        
        let realease = movie["release_date"] as! String
        realeaseLabel.text = realease
        
        let rating = movie["popularity"] as! Int
        ratingLabel.text = String(rating)+"%"
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL (string: baseUrl + posterPath)
            posterImageView.setImageWithURL(imageUrl!)
        }

    func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let id = movie!["id"] as! Int
        
        let trailerViewController = segue.destinationViewController as! TrailersViewController
        trailerViewController.id = String(id)
       
        
    }
}
