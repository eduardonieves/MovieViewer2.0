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
    
    
     var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = movie["title"] as! String
        titleLabel.text = title
        let overview = movie["overview"] as! String
        overviewLabel.text = overview as String
        overviewLabel.sizeToFit()
        
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
}