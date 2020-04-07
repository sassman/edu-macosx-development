//
//  EpisodeCell.swift
//  Pod Player
//
//  Created by Sven Aßmann on 02.04.20.
//  Copyright © 2020 Sven Aßmann. All rights reserved.
//

import Cocoa
import WebKit

class EpisodeCell: NSTableCellView {
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var pubDateLabel: NSTextField!
    @IBOutlet weak var descriptionWebView: WKWebView!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}
