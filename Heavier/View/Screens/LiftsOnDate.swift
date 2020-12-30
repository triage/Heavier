//
//  LiftsOnDate.swift
//  Overload
//
//  Created by Eric Schulte on 11/28/20.
//

import Foundation
import SwiftUI

struct LiftsOnDate: View {
    
    private var daySelected: DateComponents!
    
    init?(daySelected: DateComponents?) {
        guard let daySelected = daySelected else {
            return nil
        }
        self.daySelected = daySelected
        self.daySelected?.calendar = Calendar.current
    }
    
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
    
    private static var navigationTitleDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter
    }
    
    var body: some View {
        Lifts(dateComponents: daySelected) { (sections, _) in
            List {
                ForEach(sections ?? [LiftsSection](), id: \.id) { section in
                    let exercise = (section.objects!.first as! Lift).exercise!
                    VStack(alignment: .leading) {
                        NavigationLink(
                            destination: NavigationLazyView(
                                ExerciseView(exercise: exercise)
                            )) {
                                Text(exercise.name!)
                                    .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                                    .padding([.bottom, .top], Theme.Spacing.medium)
                            }
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
            }
            .listRowInsets(EdgeInsets())
            .navigationTitle(LiftsOnDate.navigationTitleDateFormatter.string(from: daySelected!.date!))
        }
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
