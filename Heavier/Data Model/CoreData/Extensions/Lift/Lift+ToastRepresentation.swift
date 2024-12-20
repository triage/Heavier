//
//  Lift+ToastRepresentation.swift
//  Heavier
//
//  Created by Eric Schulte on 12/19/24.
//

import Foundation

extension Lift {
    
    enum ToastReason {
        case updated
        case inserted
        
        var actionDescription: String {
            switch self {
            case .updated:
                return String(localized: "Updated")
            case .inserted:
                return String(localized: "Recorded")
            }
        }
    }
    
    struct Toast: Equatable {
        let title: String
        let subtitle: String
    }
    
    func toast(reason: ToastReason) -> Toast? {
        guard let name = exercise?.name else { return nil }
        let weight = weightLocalized(units: Settings.shared.units)
        let weightDescription = weight != nil ? "@\(weight!) \(Settings.shared.units.label)" : ""
        return Toast(
            title: String(localized: "\(reason.actionDescription) \(name)"),
            subtitle: String(localized: "\(sets)x\(reps) \(weightDescription)")
        )
    }
}
