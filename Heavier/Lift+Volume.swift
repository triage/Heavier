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
        reduce(0.0, { sum, element in
            sum + element.volume
        })
    }
    
    var reps: Int {
        Int(reduce(0, { sum, element in
            sum + Int(element.sets * element.reps)
        }))
    }
    
    var isBodyweight: Bool {
        return volume == 0
    }
}
