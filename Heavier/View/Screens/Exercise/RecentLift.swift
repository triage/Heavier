//
//  RecentLift.swift
//  Heavier
//
//  Created by Eric Schulte on 1/9/21.
//

import Foundation
import SwiftUI

struct RecentLiftMetric: View {
    let value: CustomStringConvertible
    let label: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(value.description)
                .sfCompactDisplay(.medium, size: 44.0)
                .minimumScaleFactor(0.2)
                .lineLimit(0)
            Text(label)
                .sfCompactDisplay(.medium, size: Theme.Font.Size.medium)
                .lineLimit(0)
                .padding([.top], -Theme.Spacing.medium)
        }
    }
}

struct RecentLift: View {
    let lift: Lift?
    
    var volume: String? {
        guard let lift = lift else {
            return nil
        }
        let localized = Lift.localize(weight: lift.volume)
        let number = NSNumber(value: localized)
        return Lift.weightsFormatter.string(from: number)
    }
    
    var body: some View {
        if let lift = lift, let volume = volume {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Most recent lift:", comment: "Most recent lift")
                            .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                        Text(MostRecentLift.lastLiftDateFormatter.string(from: lift.timestamp!))
                            .sfCompactDisplay(.bold, size: Theme.Font.Size.mediumPlus)
                    }
                }.padding([.bottom], Theme.Spacing.small)
                
                HStack(spacing: Theme.Spacing.giga) {
                    RecentLiftMetric(value: lift.sets, label: "sets")
                    RecentLiftMetric(value: lift.reps, label: "reps")
                    if !lift.isBodyweight {
                        RecentLiftMetric(
                            value: Lift.weightsFormatter.string(from: NSNumber(value: lift.weightLocalized.weight))!,
                            label: "weight (\(Settings.shared.units.label))"
                        )
                    }
                    Spacer()
                }
                if !lift.isBodyweight {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(volume)
                                .sfCompactDisplay(.medium, size: Theme.Font.Size.giga)
                                .minimumScaleFactor(1.0)
                                .lineLimit(1)
                            Text("total volume (\(Settings.shared.units.label))")
                                .sfCompactDisplay(.medium, size: Theme.Font.Size.medium)
                        }
                    }
                }
                
                if let notes = lift.notes, notes.count > 0 {
                    Text(notes)
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.mediumPlus)
                        .padding([.top], Theme.Spacing.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], Theme.Spacing.large)
        } else {
            EmptyView()
        }
    }
}
