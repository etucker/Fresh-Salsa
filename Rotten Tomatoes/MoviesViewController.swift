//
//  MoviesViewController.swift
//  Rotten Tomatoes
//
//  Created by Eli Tucker on 8/27/15.
//  Copyright (c) 2015 Eli Tucker. All rights reserved.
//

import UIKit
import AFNetworking
import KVNProgress

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!

    var allMovies: [NSDictionary]?
    var movies: [NSDictionary]?
    var searchActive = false
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        KVNProgress.show()
        loadAndDisplay( { KVNProgress.dismiss() } )
    }

    func loadAndDisplay(endLoadCallback: () -> Void) {
        
        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
        // if I need to run on the airplane.
        //        let url = NSURL(string: "file:///Users/eli/dev/codepath/rotten-data.json")!
        
        let request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if (error != nil) {
                self.networkErrorView.hidden = false
                println("Error!")
                println(error)
            } else {
                self.networkErrorView.hidden = true
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                if let json = json {
                    self.allMovies = json["movies"] as? [NSDictionary]
                    self.movies = self.allMovies
                    self.tableView.reloadData()
                }
            }
            endLoadCallback()
        }
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        
        let posterUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)
        if let posterUrl = posterUrl {
            cell.posterView.setImageWithURL(posterUrl)
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // ---- refresh stuff
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
//      For testing:
//        delay(2, closure: {
//            self.refreshControl.endRefreshing()
//        })
        loadAndDisplay( { self.refreshControl.endRefreshing() } )
    }
    
    // ---- end refresh stuff
    
    
    // Search stuff
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        movies = allMovies!.filter({ (movie) -> Bool in
            let tmp: NSString = movie["title"] as! NSString
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(movies!.count == 0){
            deactivateSearch()
        } 
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        deactivateSearch()
    }
    
    
    func deactivateSearch() {
        movies = allMovies
        self.tableView.reloadData()
        println("calling resign first responder")
        dispatch_async(dispatch_get_main_queue()) {
//            self.searchBar.resignFirstResponder()
            view.endEditing(true)
        }
    }
    
    // end search stuff
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        let movie = movies![indexPath.row]
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }

}
