//
//  LiftsOnDate.swift
//  Overload
//
//  Created by Eric Schulte on 11/28/20.
//

import Foundation
import SwiftUI

struct LiftsOnDate: View {
    private var fetchRequest: FetchRequest<Lift>
    private var daySelected: DateComponents?
    
    init?(daySelected: DateComponents?) {
        guard let daySelected = daySelected else {
            return nil
        }
        self.daySelected = daySelected
        self.daySelected?.calendar = Calendar.current
        fetchRequest = FetchRequest<Lift>(
            entity: Lift.entity(),
            sortDescriptors: [
                Lift.SortDescriptor.timestamp(ascending: true)
            ],
            predicate: Lift.Predicate.daySelected(daySelected)
        )
    }
    
    var lifts: FetchedResults<Lift> {
        return fetchRequest.wrappedValue
    }
    
    func volume(lifts: [Lift]) -> String {
        "= \(Lift.volumeFormatter.string(from: lifts.volume as NSNumber)!) lbs"
    }
    
    private static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(lifts.exercises.keys), id: \.self) { key in
                    let lifts = self.lifts.exercises[key]!
                    
                    VStack(alignment: .leading) {
                        Text(key)
                            .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                            .padding([.bottom], Theme.Spacing.medium)
                        
                        ForEach(lifts, id: \.self) { lift in
                            Text(lift.shortDescription(units: Settings.shared.units))
                                .sfCompactDisplay(.regular, size: Theme.Font.Size.mediumPlus)
                        }
                        
                        Text(volume(lifts: lifts))
                            .sfCompactDisplay(.medium, size: Theme.Font.Size.mediumPlus)
                            .padding([.top, .bottom], Theme.Spacing.medium)
                    }
                    
                }
            } .listRowInsets(EdgeInsets())
            .navigationTitle(LiftsOnDate.dateFormatter.string(from: daySelected!.date!))
        }
    }
}

struct LiftsOnDate_Previews: PreviewProvider {
    
    static var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
    
    static var previews: some View {
        Group {
                LiftsOnDate(daySelected: LiftsOnDate_Previews.components)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
