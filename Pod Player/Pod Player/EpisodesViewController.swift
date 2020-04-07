//
//  EpisodesViewController.swift
//  Pod Player
//
//  Created by Sven Aßmann on 01.04.20.
//  Copyright © 2020 Sven Aßmann. All rights reserved.
//

import Cocoa
import AVFoundation

class EpisodesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var pausePlayButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    var podcast: Podcast? = nil
    var podcastsVC: PodcastsViewController? = nil
    var episodes: [Episode] = []
    var player: AVPlayer? = nil
    var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        updateView()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let e = episodes[row]
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "episodeCell"), owner: self) as? EpisodeCell {
            cell.titleLabel.stringValue = e.title
            cell.descriptionWebView.loadHTMLString(e.htmlDescription, baseURL: nil)
            cell.pubDateLabel.stringValue = e.pubDate.toShortString()

            return cell
        }
        
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 100
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow >= 0 {
            let e = episodes[tableView.selectedRow]
            if let url = URL(string: e.audioURL) {
                stop();

                player = AVPlayer(url: url)
                player?.play()
                pausePlayButton.isHidden = false
            }
        }
    }
    
    func updateView() {
        if let p = podcast {
            fetchEpisodes()
            tableView.isHidden = false
            deleteButton.isHidden = false

            if p.title != nil {
                titleLabel.stringValue = p.title!
            }
            if p.imageURL != nil {
                imageView.image = NSImage(byReferencing: URL(string: p.imageURL!)!)
            }
        } else {
            titleLabel.stringValue = ""
            imageView.image = nil
            stop()
            tableView.isHidden = true
            deleteButton.isHidden = true
        }
    }
    
    func fetchEpisodes() {
        if let rssUrl = podcast?.rssURL {
            let appDel = (NSApplication.shared.delegate as? AppDelegate)
            let context = appDel?.persistentContainer.viewContext
            let url = URL(string: rssUrl)!
            
            URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil {
                    print(error)
                } else {
                    if data != nil {
                        let parser = Parser()
                        self.episodes = parser.getEpisodes(data: data!)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }.resume()
        }
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        let appDel = (NSApplication.shared.delegate as? AppDelegate)
        if let context = appDel?.persistentContainer.viewContext {
            if podcast != nil {
                context.delete(podcast!)
                appDel?.saveAction(nil)
                podcastsVC?.getPodcasts()
                podcast = nil
                stop();
                updateView()
            }
        }
    }
    
    
    @IBAction func pausePlayClicked(_ sender: Any) {
        if pausePlayButton.title == "Pause" {
            player?.pause()
            pausePlayButton.title = "Resume"
        } else {
            player?.play()
            pausePlayButton.title = "Pause"
        }
    }
    
    func stop() {
        player?.pause()
        player = nil
        pausePlayButton.title = "Pause"
        pausePlayButton.isHidden = true
    }
}
