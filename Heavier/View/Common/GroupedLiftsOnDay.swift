//
//  GroupedLiftsOnDay.swift
//  Heavier
//
//  Created by Eric Schulte on 12/20/20.
//

import Foundation
import SwiftUI
import Combine

struct GroupedLiftsOnDay: View {
    let groups: [[Lift]]
    
    var body: some View {
        ForEach(groups, id: \.identifiableHashValue) { lifts in
            VStack(alignment: .leading) {
                if let shortDescription = lifts.shortDescription(units: Settings.shared.units) {
                    Text(shortDescription)
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.mediumPlus)
                    if lifts.notes.count > 0 {
                        Text(lifts.notes)
                            .multilineTextAlignment(.leading)
                            .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                            .padding([.bottom], Theme.Spacing.small)
                    }
                }
            }
        }
    }
}

struct GroupedLiftsOnDay_Preview: PreviewProvider {
    static var previews: some View {
        
        Settings.shared.units = .metric
        
        let moc = PersistenceController.preview.container.viewContext
        
        let exercise = Exercise(context: moc)
        exercise.name = "Romanian Deadlift"
        exercise.id = UUID()
        var lifts = [Lift]()
        let secondsPerDay: TimeInterval = 60 * 60 * 24
        for date in [Date(), Date().addingTimeInterval(secondsPerDay), Date().addingTimeInterval(secondsPerDay * 2)] {
            for index in 0...3 {
                let lift = Lift(context: moc)
                lift.reps = 10 + Int16(index)
                lift.sets = 1
                lift.notes = "Middle\nHigh Outside"
                lift.weight = 20
                lift.id = UUID()
                lift.timestamp = date
                lifts.append(lift)
            }
        }
        return NavigationView {
            GroupedLiftsOnDay(groups: [lifts])
        }.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

