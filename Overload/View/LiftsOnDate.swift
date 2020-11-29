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
        ForEach(Array(exercises.keys), id: \.self) { key in
            let lifts = exercises[key]!
            
            VStack(alignment: .leading) {
                Text(key)
                    .sfCompactDisplay(.medium, size: 24.0)
                    .padding(12.0)
                
                ForEach(lifts, id: \.self) { lift in
                    Text(lift.shortDescription)
                        .sfCompactDisplay(.regular, size: 16.0)
                        .padding(EdgeInsets(top: 0.0, leading: 12.0, bottom: 0.0, trailing: 12.0))
                }
                
                Text(volume(lifts: lifts))
                    .sfCompactDisplay(.medium, size: 18.0)
                    .padding(12.0)
                
                Path { path in
                    path.move(to: CGPoint(x: 10.0, y: 0.0))
                    path.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: 0.0))
                }
                .stroke(Color.calendarDay_default, lineWidth: 1)
                .frame(height: 4.0)
            }.padding(EdgeInsets(top: 0.0, leading: 10.0, bottom: 0.0, trailing: 10.0))
            
        }
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
