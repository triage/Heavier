//
//  LiftsOnDate.swift
//  Overload
//
//  Created by Eric Schulte on 11/28/20.
//

import Foundation
import SwiftUI
import CoreData

struct LiftsOnDateView: View {
    
    @StateObject var lifts: LiftsObservable
    private let daySelected: DateComponents
    
    init?(daySelected: DateComponents?, managedObjectContext: NSManagedObjectContext) {
        guard var daySelected = daySelected else {
            return nil
        }
        daySelected.calendar = Calendar.autoupdatingCurrent
        self.daySelected = daySelected
        _lifts = .init(wrappedValue: LiftsObservable(dateComponents: daySelected, managedObjectContext: managedObjectContext))
    }
    
    private static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }
    
    struct Row: View {
        let section: LiftsSection
        
        func volume(lifts: [Lift]) -> String? {
            if lifts.isBodyweight {
                return "\(lifts.reps) reps"
            }
            guard
                let volume = Lift.localize(weight: lifts.volume),
                let formatted = Lift.weightsFormatter.string(from: NSNumber(value: volume)) else {
                    return nil
            }
            return "= \(formatted) \(Settings.shared.units.label)"
        }
        
        @Environment(\.managedObjectContext) var managedObjectContext

        var body: some View {
            NavigationLink(
                destination: ExerciseView(exercise: section.exercise, managedObjectContext: managedObjectContext),
                label: {
                    VStack(alignment: .leading) {
                        Text(section.exercise.name!)
                            .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                            .padding([.bottom, .top], Theme.Spacing.medium)
                        
                        if let lifts = section.lifts, let groups = section.groups {
                            GroupedLiftsOnDay(groups: groups)

                            if let volume = volume(lifts: lifts) {
                                Text(volume)
                                    .sfCompactDisplay(.medium, size: Theme.Font.Size.mediumPlus)
                                    .padding([.top, .bottom], Theme.Spacing.medium)
                            }
                        }
                    }
                }
            )
        }
    }
    
    var navigationTitle: String? {
        guard let date = daySelected.date else {
            return nil
        }
        return LiftsOnDateView.dateFormatter.string(from: date)
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(lifts.sections, id: \.id) { section in
                    Row(section: section)
                }
            }
            .listRowInsets(EdgeInsets())
        }
        .navigationTitle(navigationTitle ?? "")
    }
}

struct LiftsOnDate_Previews: PreviewProvider {
    
    static var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
    
    let lifts = Exercise.Preview.preview.lifts!.array as! [Lift]
    
    static var previews: some View {
        Group {
            LiftsOnDateView(daySelected: LiftsOnDate_Previews.components, managedObjectContext: PersistenceController.preview.container.viewContext)
        }.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
