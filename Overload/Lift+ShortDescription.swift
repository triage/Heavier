//
//  Lift+ShortDescription.swift
//  Overload
//
//  Created by Eric Schulte on 10/30/20.
//

import Foundation

extension Lift {
    var shortDescription: String {
        "\(sets) x \(reps) @\(Lift.weightsFormatter.string(from: weight as NSNumber)!)"
    }
}
