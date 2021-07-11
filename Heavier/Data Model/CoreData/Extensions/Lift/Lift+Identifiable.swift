//
//  Lift+Identifiable.swift
//  Heavier
//
//  Created by Eric Schulte on 7/4/21.
//

import Foundation

extension Array where Element == Lift {
    var identifiableHashValue: String {
        compactMap { lift in
            "\(lift.shortDescription(units: Settings.shared.units))"
        }.joined(separator: "-")
    }
}
