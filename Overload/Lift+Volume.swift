//
//  Lift+Volume.swift
//  Overload
//
//  Created by Eric Schulte on 10/31/20.
//

import Foundation

extension Lift {
    var volume: Float {
        return Float(sets) * Float(reps) * Float(weight)
    }
    
    struct DefaultValues {
        static let sets = 5
        static let reps = 5
        static let weight = 45
    }
}

extension Array where Element == Lift {
    var volume: Float {
        var volume: Float = 0
        for lift in self {
            volume += lift.volume
        }
        return volume
    }
}
