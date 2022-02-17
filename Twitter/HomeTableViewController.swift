//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Guest User on 2/15/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var tweetArray = [NSDictionary]()
    var numberOfTweet: Int!

    // Refresh whenever you pull down the screen
    let myRefreshControl = UIRefreshControl()
    
    // When we load our screen
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        
        // Refresh our screen
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

    }
    
    
    @objc func loadTweets(){
        
        
        numberOfTweet = 20
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numberOfTweet]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams, success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            // Reload the data every time we do a call to API and repopulate our list
            self.tableView.reloadData()
            
            // After you update the list, then stop refreshing
            self.myRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print(Error.localizedDescription)
        })
        
    }
    
    // Load infinite tweets
    func loadMoreTweets(){
        
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        
        // Add 20 tweets to the current number of tweets
        numberOfTweet = numberOfTweet + 20
        let myParams = ["count": numberOfTweet]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams, success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            // Reload the data every time we do a call to API and repopulate our list
            self.tableView.reloadData()
            
        }, failure: { (Error) in
            print(Error.localizedDescription)
        })
        
        
    }
    
    // When the user reaches the bottom of the page, run loadMoreTweets() that generates infinite tweets
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    
    
    
    
    
    

    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetcontent.text = tweetArray[indexPath.row]["text"] as? String
        
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        return cell
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

    
}
