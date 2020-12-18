//
//  LiftsOnDate.swift
//  Overload
//
//  Created by Eric Schulte on 11/28/20.
//

import Foundation
import SwiftUI

struct LiftsOnDate: View {
    
    @ObservedObject var lifts: LiftsObservable
    private var daySelected: DateComponents?
    
    init?(daySelected: DateComponents?) {
        guard let daySelected = daySelected else {
            return nil
        }
        self.daySelected = daySelected
        self.daySelected?.calendar = Calendar.current
        lifts = LiftsObservable(dateComponents: daySelected)
    }
    
    func volume(lifts: [Lift]) -> String? {
        guard
            let volume = Lift.localize(weight: lifts.volume),
            let formatted = Lift.weightsFormatter.string(from: NSNumber(value: volume)) else {
                return nil
        }
        return "= \(formatted) \(Settings.shared.units.label)"
    }
    
    private static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }
    
    struct Lifts: View {
        let lifts: [Lift]
        var body: some View {
            ForEach(Array(lifts.groupedByWeightAndReps.values).sorted(by: { (first, second) -> Bool in
                first.mostRecent.timestamp! < second.mostRecent.timestamp!
            }), id: \.self) { lifts in
                if let shortDescription = lifts.shortDescription(units: Settings.shared.units) {
                    Text(shortDescription)
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.mediumPlus)
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(lifts.sections, id: \.name) { section in
                    let exercise = (section.objects!.first as! Lift).exercise!
                    VStack(alignment: .leading) {
                        NavigationLink(
                            destination: ExerciseView(exercise: exercise)) {
                                Text(exercise.name!)
                                    .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                                    .padding([.bottom, .top], Theme.Spacing.medium)
                            }
                        if let lifts = section.objects as? [Lift] {
                            Lifts(lifts: lifts)

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
            .navigationTitle(LiftsOnDate.dateFormatter.string(from: daySelected!.date!))
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
