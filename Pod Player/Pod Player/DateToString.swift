//
//  DateToString.swift
//  Pod Player
//
//  Created by Sven Aßmann on 02.04.20.
//  Copyright © 2020 Sven Aßmann. All rights reserved.
//

import Foundation

extension Date {
    func toString(format: String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        return dateformatter.string(from: self)
    }
    
    func toShortString() -> String {
        return toString(format: "MMM d, yyyy")
    }
}
