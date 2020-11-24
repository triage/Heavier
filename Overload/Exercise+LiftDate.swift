//
//  Exercise+LiftDate.swift
//  Overload
//
//  Created by Eric Schulte on 11/22/20.
//

import Foundation

extension Exercise {
    var lastLiftDate: Date? {
        return lastLift?.timestamp
    }
    var lastLift: Lift? {
        return (lifts?.array as? [Lift])?.sorted {
            
            if $0.timestamp != nil && $1.timestamp == nil {
                return true
            } else if $0.timestamp == nil && $1.timestamp != nil {
                return false
            }
            
            guard let first = $0.timestamp, let second = $1.timestamp else {
                return true
            }
            return first > second
        }.first
    }
}
