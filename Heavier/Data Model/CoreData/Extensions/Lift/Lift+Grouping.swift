//
//  Lift+Grouping.swift
//  Overload
//
//  Created by Eric Schulte on 12/1/20.
//

import Foundation

extension Lift {
    
    private static var dayGroupingFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-DD"
        return dateFormatter
    }
    
    private static var monthGroupingFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM"
        return dateFormatter
    }
    
    @objc var dayGroupingIdentifier: String? {
        guard let timestamp = timestamp else {
            return nil
        }
        return Lift.dayGroupingFormatter.string(from: timestamp)
    }
    
    @objc var monthGroupingIdentifier: String? {
        guard let timestamp = timestamp else {
            return nil
        }
        return Lift.monthGroupingFormatter.string(from: timestamp)
    }
    
    @objc var weightsRepsGroupingIdentifier: String {
        "\(weight) - \(reps)"
    }
}

extension RandomAccessCollection where Element == Lift {    
    var groupedByWeightAndReps: [String: [Element]] {
        Dictionary(grouping: self) { (lift) -> String in
            lift.weightsRepsGroupingIdentifier
        }
    }
}

extension Array where Element == Lift {
    var mostRecent: Element {
        return sorted { (first, second) -> Bool in
            first.timestamp! < second.timestamp!
        }.last!
    }
}
