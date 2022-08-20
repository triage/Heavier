//
//  Lift+Bounds.swift
//  Heavier
//
//  Created by Eric Schulte on 1/2/21.
//

import Foundation

extension Array where Element == Lift {
    var timestampBoundsMonths: ClosedRange<Date>? {
        guard let first = first?.timestamp, let last = last?.timestamp else {
            return nil
        }
        let bounds = [first, last].sorted()

        if let start = bounds.first,
           let end = bounds.last {
            return start.startOfMonth...end.endOfMonth
        }
        return nil
    }
    
    var day: Date? {
        guard let first = first?.timestamp else {
            return nil
        }
        return Calendar.autoupdatingCurrent.startOfDay(for: first)
    }
}
