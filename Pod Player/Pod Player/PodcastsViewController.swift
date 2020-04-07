//
//  PodcastsViewController.swift
//  Pod Player
//
//  Created by Sven Aßmann on 26.03.20.
//  Copyright © 2020 Sven Aßmann. All rights reserved.
//

import Cocoa

class PodcastsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate {

    @IBOutlet weak var podcastURLTextField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var addPodcastButton: NSButton!
    
    var podcasts: [Podcast] = []
    var episodesVC: EpisodesViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let indieHackerRatioURL = "http://feeds.backtracks.fm/feeds/indiehackers/indiehackers/feed.xml?1584576034"
        podcastURLTextField.stringValue = indieHackerRatioURL
        
        getPodcasts()
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if let podCastInput = obj.object as? NSTextField {
            let url = podCastInput.stringValue
            addPodcastButton.isEnabled = !url.isEmpty
            print("podcast inserted \(url)")
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return podcasts.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = (tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "podcastcell"), owner: self)) as? NSTableCellView
            
        if let title = podcasts[row].title {
            cell?.textField?.stringValue = title
        } else {
            cell?.textField?.stringValue = "UNKNOWN TITLE"
        }
            
        return cell
    }
    
    func podcastExists(rssURL: String) -> Bool {
        let appDel = (NSApplication.shared.delegate as? AppDelegate)
        if let context = appDel?.persistentContainer.viewContext {
            if let fr: NSFetchRequest<Podcast> = Podcast.fetchRequest() {
                fr.predicate = NSPredicate(format: "rssURL == %@", rssURL)
                if let matchingPodcasts = try? context.fetch(fr) {
                    return matchingPodcasts.count >= 1
                }
            }
        }
        return false
    }
    
    func getPodcasts() {
        let appDel = (NSApplication.shared.delegate as? AppDelegate)
        if let context = appDel?.persistentContainer.viewContext {
            if let fr: NSFetchRequest<Podcast> = Podcast.fetchRequest() {
                fr.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
                if let podcasts = try? context.fetch(fr) {
                    self.podcasts = podcasts
                    
                    // MARK: How to fix the main thread issue
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func addPodcastClicked(_ sender: Any) {
        let podcastURL = podcastURLTextField.stringValue
        if let url = URL(string: podcastURL) {
            if !podcastExists(rssURL: podcastURL) {
                let appDel = (NSApplication.shared.delegate as? AppDelegate)
                let context = appDel?.persistentContainer.viewContext
                URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
                    if error != nil {
                        print(error)
                    } else {
                        if data != nil {
                            let parser = Parser()
                            let info = parser.getPodcastMetaData(data: data!)
                            
                            let podcast = Podcast(context: context!)
                            podcast.imageURL = info.imageURL
                            podcast.title = info.title
                            podcast.rssURL = podcastURL
                                
                            appDel?.saveAction(nil)
                            self.getPodcasts()
                        }
                    }
                }.resume()
            }
            podcastURLTextField.stringValue = ""
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow >= 0 {
            let podcast = podcasts[tableView.selectedRow]
            episodesVC?.podcast = podcast
            episodesVC?.updateView()
        }
    }
}
