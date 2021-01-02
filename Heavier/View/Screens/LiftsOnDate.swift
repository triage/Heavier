//
//  LiftsOnDate.swift
//  Overload
//
//  Created by Eric Schulte on 11/28/20.
//

import Foundation
import SwiftUI

struct LiftsOnDate: View {
    
    @StateObject var lifts: LiftsObservable
    private let daySelected: DateComponents
    
    init?(daySelected: DateComponents?) {
        guard var daySelected = daySelected else {
            return nil
        }
        daySelected.calendar = Calendar.autoupdatingCurrent
        self.daySelected = daySelected
        _lifts = .init(wrappedValue: LiftsObservable(dateComponents: daySelected))
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

        var body: some View {
            NavigationLink(
                destination: ExerciseView(exercise: section.exercise),
                label: {
                    VStack(alignment: .leading) {
                        Text(section.exercise.name!)
                            .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                            .padding([.bottom, .top], Theme.Spacing.medium)
                        
                        if let lifts = section.objects as? [Lift] {
                            GroupedLiftsOnDay(lifts: lifts)

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
        return LiftsOnDate.dateFormatter.string(from: date)
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(lifts.sections, id: \.name) { section in
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
            LiftsOnDate(daySelected: LiftsOnDate_Previews.components)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
