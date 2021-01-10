//
//  OlderLifts.swift
//  Heavier
//
//  Created by Eric Schulte on 1/10/21.
//

import Foundation
import CoreData
import SwiftUI

struct OlderLifts: View {
    private let sections: [NSFetchedResultsSectionInfo]
    private let dateSelected: Date?
    
    init?(sections: [NSFetchedResultsSectionInfo]?, dateSelected: Date? = nil) {
        guard let sections = sections else {
            return nil
        }
        self.sections = sections
        self.dateSelected = dateSelected
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
    
    var body: some View {
        ScrollViewReader { (proxy: ScrollViewProxy) in
            LazyVStack(alignment: .leading) {
                ForEach(sections, id: \.name) { section in
                    let lifts = section.objects as! [Lift]
                    let day = lifts.first!.timestamp!
                    
                    VStack(alignment: .leading) {
                        
                        Text(MostRecentLift.lastLiftDateFormatter.string(from: day))
                            .sfCompactDisplay(.bold, size: Theme.Font.Size.mediumPlus)
                            .padding([.bottom, .top], Theme.Spacing.small)
                        
                        GroupedLiftsOnDay(lifts: lifts)
                        
                        if let volume = volume(lifts: lifts) {
                            Text(volume)
                                .sfCompactDisplay(.medium, size: Theme.Font.Size.mediumPlus)
                                .padding([.top], Theme.Spacing.small)
                                .padding([.bottom], Theme.Spacing.medium)
                        }
                    }.id(section.name)
                }
            }.padding([.top], LiftsCalendarView.frameHeight)
            .onChange(of: dateSelected, perform: { dateSelected in
                guard let dateSelected = dateSelected else {
                    return
                }
                let sectionId = Lift.dayGroupingFormatter.string(from: dateSelected)
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(sectionId)
                }
            })
        }
    }
}
