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
    var section: LiftsSection
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
    
    var day: Date? {
        section.lifts?.first?.timestamp
    }
    
    var body: some View {
        if let day = day {
            HStack {
                VStack(alignment: .leading) {
                    Text(MostRecentLift.lastLiftDateFormatter.string(from: day))
                        .sfCompactDisplay(.bold, size: Theme.Font.Size.mediumPlus)
                        .padding([.bottom, .top], Theme.Spacing.small)
                    
                    GroupedLiftsOnDay(lifts: section.lifts!)
                    
                    if let volume = volume(lifts: section.lifts!) {
                        Text(volume)
                            .sfCompactDisplay(.medium, size: Theme.Font.Size.mediumPlus)
                            .padding([.top], Theme.Spacing.small)
                            .padding([.bottom], Theme.Spacing.medium)
                    }
                }
                Spacer()
            }
            .padding([.leading], Theme.Spacing.large)
            .background(section.id == selectedSectionId ? Color.blue : Color.clear)
        } else {
            EmptyView()
        }
    }
}

struct OlderLifts: View {
    @State private var lifts: LiftsObservable
    
    private let exercise: Exercise
    private let dateSelected: Date?
    
    init(exercise: Exercise, dateSelected: Date? = nil) {
        self.exercise = exercise
        _lifts = .init(
            wrappedValue: LiftsObservable(exercise: exercise, ascending: false)
        )
        self.dateSelected = dateSelected
    }
    
    @State var selectedSectionId: String?
    
    var body: some View {
        ScrollViewReader { (proxy: ScrollViewProxy) in
            LazyVStack(alignment: .leading) {
                ForEach(lifts.sections, id: \.id) { section in
                    NavigationLink(
                        destination: NavigationLazyView(
                            Text("hi")
                        ),
                        label: {
                            OlderLift(section: section, selectedSectionId: selectedSectionId)
                                .id(section.id)
                        }) 
                }
            }
            .padding([.top], LiftsCalendarView.frameHeight)
            .onChange(of: dateSelected, perform: { dateSelected in
                guard let dateSelected = dateSelected else {
                    return
                }
                let duration: TimeInterval = 0.3
                self.selectedSectionId = lifts.sections.first(where: { (section) -> Bool in
                    if let day = section.lifts?.day {
                        return day == dateSelected
                    }
                    return false
                })?.id
                if let selectedSectionId = selectedSectionId {
                    withAnimation(.easeInOut(duration: duration)) {
                        proxy.scrollTo(selectedSectionId)
                    }
                    Timer.scheduledTimer(withTimeInterval: duration * 2, repeats: false) { (_) in
                        withAnimation(Animation.easeInOut(duration: 1.0).delay(duration)) {
                            self.selectedSectionId = nil
                        }
                    }
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
        
        return OlderLifts(exercise: exercise, dateSelected: Date())
    }
}
