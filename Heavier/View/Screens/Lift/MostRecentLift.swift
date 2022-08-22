//
//  MostRecentLift.swift
//  Overload
//
//  Created by Eric Schulte on 10/30/20.
//

import Foundation
import SwiftUI

struct MostRecentLift: View {
    
    static let padding: CGFloat = Theme.Spacing.medium
    static var lastLiftDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter
    }
    
    let lift: Lift?
    
    var body: some View {
        if let lift = lift,
           let timestamp = lift.timestamp {
            HStack {
                VStack(alignment: .leading) {
                    Text("most recent lift:")
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                    Text(lift.shortDescription(units: Settings.shared.units))
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.mediumPlus)
                    Text(MostRecentLift.lastLiftDateFormatter.string(from: timestamp))
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                }
                    .padding(MostRecentLift.padding)
                    .background(Color.highlight)
                    .cornerRadius(MostRecentLift.padding * 2.0)
                .foregroundColor(Color.black)
                Spacer()
            }
        } else {
            EmptyView()
        }
    }
}

struct MostRecentLift_Previews: PreviewProvider {
    static var previews: some View {
        let lift = Lift(context: PersistenceController.preview.container.viewContext)
        lift.reps = 10
        lift.sets = 3
        lift.weight = 135
        lift.id = UUID()
        lift.timestamp = Date()
        
        return Group {
            MostRecentLift(lift: lift)
            MostRecentLift(lift: lift)
                .environment(\.colorScheme, ColorScheme.dark)
        }.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
