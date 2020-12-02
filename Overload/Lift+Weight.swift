//
//  Lift+Weight.swift
//  Overload
//
//  Created by Eric Schulte on 12/1/20.
//

import Foundation
import CoreGraphics

extension Lift {
    var weightLocalized: (weight: Float, units: Settings.Units) {
        let units = Settings().units
        if units == .imperial {
            return (weight * 2.20462, Settings.Units.imperial)
        }
        return (weight, Settings.Units.metric)
    }
}
