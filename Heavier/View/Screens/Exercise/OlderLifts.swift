//
//  OlderLifts.swift
//  Heavier
//
//  Created by Eric Schulte on 1/10/21.
//

import Foundation
import CoreData
import SwiftUI

struct OlderLift: View {
    let section: NSFetchedResultsSectionInfo
    let selectedSectionId: String?
    
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
        let lifts = section.objects as! [Lift]
        let day = lifts.first!.timestamp!

        return HStack {
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
            }
            Spacer()
        }
        .padding([.leading], Theme.Spacing.large)
        .background(section.name == selectedSectionId ? Color.blue : Color.clear)
        .id(section.name)
    }
}

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
    
    @State var selectedSectionId: String?
    
    var body: some View {
        ScrollViewReader { (proxy: ScrollViewProxy) in
            LazyVStack(alignment: .leading) {
                ForEach(sections, id: \.name) { section in
                    OlderLift(section: section, selectedSectionId: selectedSectionId)
                }
            }
            .padding([.top], LiftsCalendarView.frameHeight)
            .onChange(of: dateSelected, perform: { dateSelected in
                guard let dateSelected = dateSelected else {
                    return
                }
                let duration: TimeInterval = 0.3
                selectedSectionId = Lift.dayGroupingFormatter.string(from: dateSelected)
                withAnimation(.easeInOut(duration: duration)) {
                    proxy.scrollTo(selectedSectionId)
                }
                withAnimation(Animation.easeInOut(duration: 1.0).delay(duration)) {
                    selectedSectionId = nil
                }
            })
        }
    }
}

struct OlderLiftsPreviews: PreviewProvider {
    static var previews: some View {
        
        Settings.shared.units = .metric
        
        let exercise = Exercise(context: PersistenceController.shared.container.viewContext)
        exercise.name = "Romanian Deadlift"
        exercise.id = UUID()
        var lifts = [Lift]()
        let secondsPerDay: TimeInterval = 60 * 60 * 24
        for date in [Date(), Date().addingTimeInterval(secondsPerDay), Date().addingTimeInterval(secondsPerDay * 2)] {
            for _ in 0...3 {
                let lift = Lift(context: PersistenceController.shared.container.viewContext)
                lift.reps = 10
                lift.sets = 1
                lift.notes = "Light weight, baby!"
                lift.weight = 20
                lift.id = UUID()
                lift.timestamp = date
                lifts.append(lift)
            }
        }
        exercise.lifts = NSOrderedSet(array: lifts)
        
        let observable = LiftsObservable(exercise: exercise)
        
        return OlderLifts(sections: observable.sections, dateSelected: Date())
    }
}
