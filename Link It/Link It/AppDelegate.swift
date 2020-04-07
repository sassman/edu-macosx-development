//
//  AppDelegate.swift
//  Link It
//
//  Created by Sven Aßmann on 26.03.20.
//  Copyright © 2020 Sven Aßmann. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var item: NSStatusItem? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item?.image = NSImage(named: "link")
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Link It!", action: #selector(AppDelegate.linkIt), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit), keyEquivalent: ""))
        item?.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func printPasteboard() {
        if let items = NSPasteboard.general.pasteboardItems {
            for item in items {
                for type in item.types {
                    print("Type: \(type)")
                    print("String: \(item.string(forType: type))")
                }
            }
        }
        
    }

    @objc func linkIt() {
        let typeOfInterest = "public.utf8-plain-text"
        if let items = NSPasteboard.general.pasteboardItems {
            for item in items {
                for type in item.types {
                    if type.rawValue == typeOfInterest {
                        if let url = item.string(forType: type) {
                            var actualUrl = ""
                            if url.hasPrefix("http://") || url.hasPrefix("https://") {
                                actualUrl = url
                            } else {
                                actualUrl = "http://\(url)"
                            }
                            // www.twitter.com
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString("<a href=\"\(actualUrl)\">\(url)</a>", forType: NSPasteboard.PasteboardType.html)
                            NSPasteboard.general.setString(actualUrl, forType: NSPasteboard.PasteboardType.URL)
                            NSPasteboard.general.setString(actualUrl, forType: NSPasteboard.PasteboardType.string)
                        }
                    }
                }
            }
        }
        
        printPasteboard()
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}

