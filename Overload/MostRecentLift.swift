//
//  MostRecentLift.swift
//  Overload
//
//  Created by Eric Schulte on 10/30/20.
//

import Foundation
import SwiftUI

struct MostRecentLift: View {
    
    static var lastLiftDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter
    }
    
    let lift: Lift?
    static let padding: CGFloat = 14.0
    var body: some View {
        if let lift = lift,
           let timestamp = lift.timestamp {
            HStack {
                VStack(alignment: .leading) {
                    Text("most recent lift:")
                        .sfCompactDisplay(.regular, size: 10.0)
                    Text(lift.shortDescription)
                        .sfCompactDisplay(.medium, size: 18.0)
                    Text(MostRecentLift.lastLiftDateFormatter.string(from: timestamp))
                        .sfCompactDisplay(.regular, size: 12.0)
                }
                    .padding(MostRecentLift.padding)
                    .background(Color.highlight)
                    .cornerRadius(MostRecentLift.padding * 2.0)
                Spacer()
            }
        } else {
            EmptyView()
        }
    }
}
