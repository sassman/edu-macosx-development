//
//  SplitController.swift
//  Pod Player
//
//  Created by Sven Aßmann on 01.04.20.
//  Copyright © 2020 Sven Aßmann. All rights reserved.
//

import Cocoa

class SplitController: NSSplitViewController {

    @IBOutlet weak var podcastsItem: NSSplitViewItem!
    @IBOutlet weak var episodesItem: NSSplitViewItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
            
        if let podcastVC = podcastsItem.viewController as? PodcastsViewController {
            if let episodesVC = episodesItem.viewController as? EpisodesViewController {
                podcastVC.episodesVC = episodesVC
                episodesVC.podcastsVC = podcastVC
            }
        }
    }
}
