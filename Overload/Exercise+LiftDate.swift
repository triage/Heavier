//
//  Exercise+LiftDate.swift
//  Overload
//
//  Created by Eric Schulte on 11/22/20.
//

import Foundation

extension Exercise {
    var lastLiftDate: Date? {
        return (lifts?.array as? [Lift])?.sorted {
            guard let first = $0.timestamp, let second = $1.timestamp else {
                return false
            }
            return first > second
        }.first?.timestamp
    }
}
