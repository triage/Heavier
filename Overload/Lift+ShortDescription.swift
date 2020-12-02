//
//  Lift+ShortDescription.swift
//  Overload
//
//  Created by Eric Schulte on 10/30/20.
//

import Foundation
import SwiftUI

extension Lift {
    var shortDescription: String {
        var description = "\(sets) x \(reps)"
        if !isBodyweight {
            description += " @ \(Lift.weightsFormatter.string(from: weight as NSNumber)!)"
        }
        return description
    }
    
    func shortDescription(units: Settings.Units) -> String {
        var description = "\(sets) x \(reps)"
        if !isBodyweight {
            description += " @ \(weightLocalized(units: units)!)"
        }
        return description
    }
    
    func weightLocalized(units: Settings.Units) -> String? {
        guard !isBodyweight else {
            return nil
        }
        let amount: Float
        if units == .imperial {
            amount = weight * 2.20462
        } else {
            amount = weight
        }
        return Lift.weightsFormatter.string(from: amount as NSNumber)!
    }
}
