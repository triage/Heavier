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
                    if let notes = lifts.notes, notes.count > 0 {
                        Text(notes)
                            .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                            .padding([.bottom], Theme.Spacing.small)
                    }
                }
            }
        }
    }
}
