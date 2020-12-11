//
//  Lift+ShortDescription.swift
//  Overload
//
//  Created by Eric Schulte on 10/30/20.
//

import Foundation
import SwiftUI

extension Lift {
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

extension Array where Element == Lift {
    func shortDescription(units: Settings.Units) -> String? {
        guard let first = first else {
            return nil
        }
        
        let sets = compactMap { $0.sets }.reduce(0, +)
        
        var description = "\(sets) x \(first.reps)"
        if !first.isBodyweight {
            description += " @ \(first.weightLocalized(units: units)!)"
        }
        return description
    }
}
