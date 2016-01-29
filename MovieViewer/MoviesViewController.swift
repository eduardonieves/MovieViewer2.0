//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Eduardo Nieves on 1/8/16.
//  Copyright © 2016 Eduardo Nieves. All rights reserved.
//

import UIKit
import AFNetworking
import SwiftSpinner


class MoviesViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var scrollView: UITableView!
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
   

    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var timer = NSTimer()
    var seconds = 0
    var nowPlaying = true
    var topRated = false
    var upcoming = false
    var popular = false
    var filteredMovies:[NSDictionary]!
    var endpoint = "now_playing"
    var search = false
    
    
    @IBAction func gridButton(sender: AnyObject) {
        print("entered grid")
      
            }
    
    @IBAction func nowPlayingButton(sender: AnyObject) {
        
        nowPlaying = true
        topRated = false
        upcoming = false
        popular = false
        endpoint = "now_playing"
        seconds = 0
        viewDidLoad()
        self.navigationItem.title = "Now Playing";
        
        print(endpoint)
    }
    @IBAction func topRatedButton(sender: AnyObject) {
        nowPlaying = false
        topRated = true
        upcoming = false
        popular = false
        endpoint = "top_rated"
        seconds = 0
        self.navigationItem.title = "Top Rated";
        viewDidLoad()
        print(endpoint)
        
    }
    @IBAction func upcomingButton(sender: AnyObject) {
        nowPlaying = false
        topRated = false
        upcoming = true
        popular = false
        endpoint = "upcoming"
        seconds = 0
        self.navigationItem.title = "Upcoming";
        viewDidLoad()
        print(endpoint)
    }
    @IBAction func popularButton(sender: AnyObject) {
        nowPlaying = false
        topRated = false
        upcoming = false
        popular = true
        endpoint = "popular"
        seconds = 0
        self.navigationItem.title = "Popular";
        viewDidLoad()
        print(endpoint)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        filteredMovies = movies
        
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    print("Reachable via WiFi")
                    self.networkLabel.hidden = true
                } else {
                    print("Reachable via Cellular")
                    self.networkLabel.hidden = true
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                print("Not reachable")
                self.networkLabel.hidden = false
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        
        if seconds == 0{
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: ("updateTimer"), userInfo: nil, repeats: true)
        }
        
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        scrollView.insertSubview(refreshControl, atIndex: 0)
        
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
                            //print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.filteredMovies = self.movies
                            self.tableView.reloadData()
                            
                    }
                }
        });
        task.resume()
        }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredMovies = searchText.isEmpty ? movies : movies!.filter({(movie: NSDictionary) -> Bool in
            print(movie["title"] as! String)
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                print("Reachable via WiFi")
                
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Not reachable")
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        }else{
            
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
    
        
        if seconds == 0{
            SwiftSpinner.show("Loading")
        }
        
        print("row \(indexPath.row)")
        
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        if let posterPath = movie["poster_path"] as? String{
            let baseURL = "http://image.tmdb.org/t/p/w500"
            let imagerURL = NSURL(string: baseURL + posterPath)
            cell.posterView.setImageWithURL(imagerURL!)
            }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
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
        
        
        tableView.reloadData()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "singleView"{
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let movie = filteredMovies![indexPath!.row]
            print (movie)
            
            let singleMovieController = segue.destinationViewController as! SingleMovieViewController
            singleMovieController.movie = movie

        }
        else{
            if nowPlaying == true{
                endpoint = "now_playing"
                let gridMovieController = segue.destinationViewController as! GridViewController
                gridMovieController.endpoint = endpoint
            }
           else if topRated == true{
                endpoint = "top_rated"
                let gridMovieController = segue.destinationViewController as! GridViewController
                gridMovieController.endpoint = endpoint
            }
            else if upcoming == true{
                endpoint = "upcoming"
                let gridMovieController = segue.destinationViewController as! GridViewController
                gridMovieController.endpoint = endpoint
            }
            else if popular == true{
                endpoint = "popular"
                let gridMovieController = segue.destinationViewController as! GridViewController
                gridMovieController.endpoint = endpoint
            }
        }
    }
}
