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
    
    init?(daySelected: DateComponents?) {
        guard let daySelected = daySelected else {
            return  nil
        }
        fetchRequest = FetchRequest<Lift>(
            entity: Lift.entity(),
            sortDescriptors: [],
            predicate: Lift.predicate(daySelected: daySelected)
        )
    }
    
    var lifts: FetchedResults<Lift> {
        return fetchRequest.wrappedValue
    }
    
    var exercises: [String: [Lift]] {
        return Dictionary(grouping: lifts) { (lift: Lift) -> String in
            return lift.exercise!.name!
        }
    }
    
    func volume(lifts: [Lift]) -> String {
        "= \(Lift.volumeFormatter.string(from: lifts.volume as NSNumber)!) lbs"
    }
    
    var body: some View {
        List {
            ForEach(Array(exercises.keys), id: \.self) { key in
                let lifts = exercises[key]!
                
                VStack(alignment: .leading) {
                    Text(key)
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                        .padding(Theme.Spacing.medium)
                    
                    ForEach(lifts, id: \.self) { lift in
                        Text(lift.shortDescription)
                            .sfCompactDisplay(.regular, size: Theme.Font.Size.mediumPlus)
                            .padding(EdgeInsets(top: 0.0, leading: Theme.Spacing.medium, bottom: 0.0, trailing: Theme.Spacing.medium))
                    }
                    
                    Text(volume(lifts: lifts))
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.mediumPlus)
                        .padding(Theme.Spacing.medium)
                    
                    Path { path in
                        path.move(to: CGPoint(x: SwiftUI.List.separatorInset, y: 0.0))
                        path.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: 0.0))
                    }
                    .stroke(Color.calendarDay_default, lineWidth: 1)
                    .frame(height: 4.0)
                }.padding(EdgeInsets(top: 0.0, leading: SwiftUI.List.separatorInset, bottom: 0.0, trailing: SwiftUI.List.separatorInset))
                
            }
        } .listRowInsets(EdgeInsets())
    }
}

struct LiftsOnDate_Previews: PreviewProvider {
    
    static let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
    
    static var previews: some View {
        Group {
            LazyVStack(alignment: .leading) {
                LiftsOnDate(daySelected: LiftsOnDate_Previews.components)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }.listStyle(PlainListStyle())
        }
    }
}
