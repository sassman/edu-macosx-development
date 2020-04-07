//
//  Parser.swift
//  Pod Player
//
//  Created by Sven Aßmann on 27.03.20.
//  Copyright © 2020 Sven Aßmann. All rights reserved.
//

import Foundation

class Parser {
    func getPodcastMetaData(data: Data) -> (title: String?, imageURL: String?) {
        let xml = SWXMLHash.parse(data)
        
        return (
            xml["rss"]["channel"]["title"].element?.text,
            xml["rss"]["channel"]["itunes:image"].element?.attribute(by: "href")?.text
        )
    }
    
    func getEpisodes(data: Data) -> [Episode] {
        let xml = SWXMLHash.parse(data)
        var episodes: [Episode] = []

        for item in xml["rss"]["channel"]["item"].all {
            let e = Episode()
            if let title = item["title"].element?.text {
                e.title = title
            }
            if let htmlDesc = item["description"].element?.text {
                e.htmlDescription = htmlDesc
            }
            if let audioUrl = item["enclosure"].element?.attribute(by: "url")?.text {
                e.audioURL = audioUrl
            } else if let audioUrl = item["link"].element?.text {
                e.audioURL = audioUrl
            }
            if let pubDate = item["pubDate"].element?.text {
                if let date = Parser.formatter.date(from: pubDate) {
                    e.pubDate = date
                }
            }
            
            episodes.append(e)
        }
        
        return episodes
    }
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter
    }()
}
