//
//  GridViewController.swift
//  MovieViewer
//
//  Created by Eduardo Nieves on 1/27/16.
//  Copyright © 2016 Eduardo Nieves. All rights reserved.
//

import UIKit
import AFNetworking
import SwiftSpinner

class GridViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var timer = NSTimer()
    var seconds = 0
    var nowPlaying = true
    var topRated = false
    var filteredMovies:[NSDictionary]!
    var endpoint: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        print(endpoint)
        
        if endpoint == "now_playing"{
            self.navigationItem.title = "Now Playing";
        }
        else if endpoint == "top_rated"{
            self.navigationItem.title = "Top Rated";
        }
        else if endpoint == "upcoming"{
            self.navigationItem.title = "Upcoming";
        }
        else if endpoint == "popular"{
            self.navigationItem.title = "Popular";
        }
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)

        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.filteredMovies = self.movies
                            self.collectionView.reloadData()
                            
                    }
                }
        });
        task.resume()
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        }else{
            
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("com.codepath.CollectionCell", forIndexPath: indexPath) as!  MoviesCollectionViewCell
        
        if seconds < 1{
            SwiftSpinner.show("Loading")
        }

        print("row \(indexPath.row)")
        
        let movie = filteredMovies![indexPath.row]
        if let posterPath = movie["poster_path"] as? String{
            let baseURL = "http://image.tmdb.org/t/p/w500"
            let imagerURL = NSURL(string: baseURL + posterPath)
            cell.posterView.setImageWithURL(imagerURL!)
        }
        
       updateTimer()
        return cell
    }

    func updateTimer(){
        seconds++
        if seconds >= 1{
            timer.invalidate()
            SwiftSpinner.hide()
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
        collectionView.reloadData()
    }
   /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
*/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let singleMovieController = segue.destinationViewController as! SingleMovieViewController
        singleMovieController.movie = movie
    }


}
