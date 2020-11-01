//
//  Lift+Volume.swift
//  Overload
//
//  Created by Eric Schulte on 10/31/20.
//

import Foundation

extension Lift {
    var volume: Int {
        return Int(sets) * Int(reps) * Int(weight)
    }
    
    struct DefaultValues {
        static let sets = 5
        static let reps = 5
        static let weight = 45
    }
}
