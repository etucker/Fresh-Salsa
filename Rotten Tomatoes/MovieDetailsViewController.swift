//
//  MovieDetailsViewController.swift
//  Rotten Tomatoes
//
//  Created by Eli Tucker on 8/30/15.
//  Copyright (c) 2015 Eli Tucker. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String
        
        // Alter the URL to get the full size image
        // Original URL looks like this: "http://resizing.flixster.com/q7N6i-lodgiFIv2pn2fKcITzDFw=/o/dkpu1ddg7pbsk.cloudfront.net/movie/11/19/07/11190713_ori.jpg"
        var urlString = movie.valueForKeyPath("posters.thumbnail") as! String
        var range = urlString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            urlString = urlString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }

        posterImageView.setImageWithURL(NSURL(string: urlString)!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
    }
    

}
