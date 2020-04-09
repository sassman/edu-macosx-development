//
//  ViewController.swift
//  TweetGram
//
//  Created by Sven Aßmann on 04.04.20.
//  Copyright © 2020 d34dl0ck. All rights reserved.
//

import Cocoa
import OAuthSwift
import SwiftyJSON
import Kingfisher

class ViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    @IBOutlet weak var loginLogoutButton: NSButton!
    @IBOutlet weak var collectionView: NSCollectionView!
    
    var oauthswift: OAuth1Swift = OAuth1Swift(
        consumerKey:    ProcessInfo.processInfo.environment["twitterApiKey"]!.string,
        consumerSecret: ProcessInfo.processInfo.environment["twitterApiSecret"]!.string,
        requestTokenUrl: "https://api.twitter.com/oauth/request_token",
        authorizeUrl:    "https://api.twitter.com/oauth/authorize", 
        accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
    )
    var tweetURLs: [(String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 300, height: 300)
        layout.sectionInset = NSEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        collectionView.collectionViewLayout = layout
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        checkLogin()
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweetURLs.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TweetGramItem"), for: indexPath)
        
        let image = tweetURLs[indexPath.item]
        let url = URL(string: image.0)
        item.imageView?.kf.setImage(with: url)
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let i = indexPaths.first?.item {
            let tweet = tweetURLs[i].1
            if let url = URL(string: tweet) {
                NSWorkspace.shared.open(url)
            }
        }
        collectionView.deselectAll(nil)
    }
    
    @IBAction func loginLogoutClicked(_ sender: Any) {
        if loginLogoutButton.title == "Login" {
            login()
        } else {
            logout()
        }
    }
    
    func checkLogin() {
        if let oauthToken = UserDefaults.standard.string(forKey: "oauthToken") {
            if let oauthTokenSecret = UserDefaults.standard.string(forKey: "oauthTokenSecret") {
                oauthswift.client.credential.oauthToken = oauthToken
                oauthswift.client.credential.oauthTokenSecret = oauthTokenSecret
                
                loginLogoutButton.title = "Logout"
                fetchTimeline()
            }
        }
    }
    
    func login() {
        // authorize
        oauthswift.authorize(
        withCallbackURL: URL(string: "TweetGram://twitter-login-suceeded")!) { result in
            switch result {
            case .success(let (credential, response, parameters)):
                UserDefaults.standard.set(credential.oauthToken, forKey: "oauthToken")
                UserDefaults.standard.set(credential.oauthTokenSecret, forKey: "oauthTokenSecret")
                UserDefaults.standard.synchronize()
                self.loginLogoutButton.title = "Logout"
                
                self.fetchTimeline()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "oauthToken")
        UserDefaults.standard.removeObject(forKey: "oauthTokenSecret")
        UserDefaults.standard.synchronize()
        loginLogoutButton.title = "Login"
        
        self.tweetURLs = []
        self.collectionView.reloadData()
    }
    
    func fetchTimeline() {
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        
        oauthswift.client.get(url, parameters: [
            "tweet_mode":"extended",
            "count": 200
        ]) { result in
            switch result {
            case .success(let response):
                do {
                    let tweets = try JSON(data: response.data)
                    
                    for (_, tweet):(String, JSON) in tweets {
                        self.handleJsonTweet(tweet: tweet)
                    }
                } catch {
                    print(error)
                }
                self.collectionView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func handleJsonTweet(tweet: JSON) {
        var retweeded = false
        for (_, image):(String, JSON) in tweet["retweeded_status"]["extended_entities"]["media"] {
            retweeded = true
            let tweetTuple = (
                image["media_url_https"].stringValue,
                image["expanded_url"].stringValue
            )
            self.tweetURLs.append(tweetTuple)
        }
        if !retweeded {
            for (_, image):(String, JSON) in tweet["extended_entities"]["media"] {
                let tweetTuple = (
                    image["media_url_https"].stringValue,
                    image["expanded_url"].stringValue
                )
                self.tweetURLs.append(tweetTuple)
            }
        }
    }
}

