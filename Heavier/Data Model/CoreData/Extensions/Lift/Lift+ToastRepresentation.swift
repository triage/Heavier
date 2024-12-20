//
//  Lift+ToastRepresentation.swift
//  Heavier
//
//  Created by Eric Schulte on 12/19/24.
//

import Foundation

extension Lift {
    
    struct Toast: Equatable {
        let title: String
        let subtitle: String
    }
    
    var toast: Toast? {
        guard let name = exercise?.name else { return nil }
        let weight = weightLocalized(units: Settings.shared.units)
        let weightDescription = weight != nil ? "@\(weight!) \(Settings.shared.units.label)" : ""
        return Toast(
            title: String(localized: "Recorded \(name)"),
            subtitle: String(localized: "\(sets)x\(reps) \(weightDescription)")
        )
    }
}
