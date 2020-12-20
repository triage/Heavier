//
//  GroupedLiftsOnDay.swift
//  Heavier
//
//  Created by Eric Schulte on 12/20/20.
//

import Foundation
import SwiftUI

struct GroupedLiftsOnDay: View {
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
