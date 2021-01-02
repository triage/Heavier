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
            return (weight * Constants.Measurement.Conversion.MetricImperialConversion.factor, Settings.Units.imperial)
        }
        return (weight, Settings.Units.metric)
    }
    
    static func normalize(weight: Float) -> Float {
        if Settings.shared.units == .metric {
            return weight
        }
        return weight / Constants.Measurement.Conversion.MetricImperialConversion.factor
    }
    
    static func localize(weight: Float?) -> Float? {
        guard let weight = weight else {
            return nil
        }
        if Settings.shared.units == .imperial {
            return weight * Constants.Measurement.Conversion.MetricImperialConversion.factor
        }
        return weight
    }
}
