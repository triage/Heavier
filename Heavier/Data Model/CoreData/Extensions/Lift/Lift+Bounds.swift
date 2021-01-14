//
//  Lift+Bounds.swift
//  Heavier
//
//  Created by Eric Schulte on 1/2/21.
//

import Foundation

extension Array where Element == Lift {
    var timestampBounds: ClosedRange<Date>? {
        guard let first = first?.timestamp, let last = last?.timestamp else {
            return nil
        }
        let bounds = [first, last].sorted()
        return bounds.first!...bounds.last!
    }
    
    var day: Date? {
        guard let first = first?.timestamp else {
            return nil
        }
        return Calendar.autoupdatingCurrent.startOfDay(for: first)
    }
}
