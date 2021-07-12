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
    
    /*
     Start: start of month of first date
     End: end of month of last date
     
     */
    var timestampBoundsMonths: ClosedRange<Date>? {
        guard let first = first?.timestamp, let last = last?.timestamp else {
            return nil
        }
        let bounds = [first, last].sorted()
        let calendar = Calendar.autoupdatingCurrent
        
        if let first = bounds.first,
           let last = bounds.last,
           let start = calendar.date(from: calendar.dateComponents([.year, .month], from: first)),
           let end = calendar.date(from: calendar.dateComponents([.year, .month], from: last)) {
            return start...end
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
