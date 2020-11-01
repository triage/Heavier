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
}
