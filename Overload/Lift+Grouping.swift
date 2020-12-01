//
//  Lift+Grouping.swift
//  Overload
//
//  Created by Eric Schulte on 12/1/20.
//

import Foundation

extension RandomAccessCollection where Element == Lift {
    var exercises: [String: [Element]] {
        return Dictionary(grouping: self) { (lift: Element) -> String in
            return lift.exercise!.name!
        }
    }
    
    var exercisesGroupedByDay: [Date: [Element]] {
        return Dictionary(grouping: self) { (lift: Element) -> Date in
            return Lift.dayFormatter.date(from: lift.day!)!
        }
    }
}
