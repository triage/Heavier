//
//  Lift+ShortDescription.swift
//  Overload
//
//  Created by Eric Schulte on 10/30/20.
//

import Foundation

extension Lift {
    var shortDescription: String {
        var description = "\(sets) x \(reps)"
        if !isBodyweight {
            description += " @ \(Lift.weightsFormatter.string(from: weight as NSNumber)!)"
        }
        return description
    }
}
