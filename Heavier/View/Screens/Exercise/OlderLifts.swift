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
        let volume = Lift.localize(weight: lifts.volume)
        guard
            let formatted = Lift.weightsFormatter.string(from: NSNumber(value: volume)) else {
                return nil
        }
        return "= \(formatted) \(Settings.shared.units.label)"
    }
    
    var day: Date? {
        section.lifts?.first?.timestamp
    }
    
    var body: some View {
        if let day = day, let groups = section.groups {
            HStack {
                VStack(alignment: .leading) {
                    Text(MostRecentLift.lastLiftDateFormatter.string(from: day))
                        .sfCompactDisplay(.bold, size: Theme.Font.Size.mediumPlus)
                        .padding([.bottom, .top], Theme.Spacing.small)
                    
                    GroupedLiftsOnDay(groups: groups)
                    
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
    private class DateObservable: ObservableObject {
        @Published var date: Date = Date()
    }
    
    @Environment(\.managedObjectContext) var context
    
    @StateObject private var lifts: LiftsObservable
    @StateObject private var olderLiftDateSelected = DateObservable()
    
    @State var selectedSectionId: String?
    @State var isPresented = false
    
    @Binding var dateSelected: Date?
    
    private let exercise: Exercise
    private static let scrollAnimationDuration: TimeInterval = 0.3

    init(exercise: Exercise, dateSelected: Binding<Date?>, managedObjectContext: NSManagedObjectContext) {
        self.exercise = exercise
        self._dateSelected = dateSelected

        _lifts = .init(
            wrappedValue: LiftsObservable(
                exercise: exercise,
                context: managedObjectContext,
                ascending: false
            )
        )
    }
    
    var body: some View {
        return ScrollViewReader { (proxy: ScrollViewProxy) in
            NavigationLink(
                destination: NavigationLazyView(ExerciseOnDate(exercise: exercise, date: olderLiftDateSelected.date, context: context)),
                isActive: $isPresented,
                label: {
                    EmptyView()
                }
            )
            LazyVStack(alignment: .leading) {
                ForEach(lifts.sections, id: \.id) { section in
                    Button(action: {
                        olderLiftDateSelected.date = section.lifts!.first!.timestamp!
                        isPresented = true
                    }, label: {
                        OlderLift(section: section, selectedSectionId: selectedSectionId)
                            .id(section.id)
                    })
                }
            }
            .padding([.top], LiftsCalendarView.frameHeight)
            .onChange(of: dateSelected) { _, dateSelected in
                guard let dateSelected = dateSelected else {
                    return
                }
                self.selectedSectionId = lifts.sections.first(where: { (section) -> Bool in
                    if let day = section.lifts?.day {
                        return day == dateSelected
                    }
                    return false
                })?.id
                if let selectedSectionId = selectedSectionId {
                    withAnimation(.easeInOut(duration: OlderLifts.scrollAnimationDuration)) {
                        proxy.scrollTo(selectedSectionId)
                    }
                    Timer.scheduledTimer(
                        withTimeInterval: OlderLifts.scrollAnimationDuration * 2,
                        repeats: false
                    ) { (_) in
                        withAnimation(Animation.easeInOut(duration: 1.0).delay(OlderLifts.scrollAnimationDuration)) {
                            self.selectedSectionId = nil
                        }
                    }
                }
            }
        }
    }
}

extension OlderLifts: Equatable {
    static func == (lhs: OlderLifts, rhs: OlderLifts) -> Bool {
        lhs.exercise.lifts == rhs.exercise.lifts
    }
}

struct OlderLiftsPreviews: PreviewProvider {
    static var previews: some View {
        
        Settings.shared.units = .metric
        
        let moc = PersistenceController.preview.container.viewContext
        
        let exercise = Exercise(context: moc)
        exercise.name = "Romanian Deadlift"
        exercise.id = UUID()
        var lifts = [Lift]()
        let secondsPerDay: TimeInterval = 60 * 60 * 24
        for date in [Date(), Date().addingTimeInterval(secondsPerDay), Date().addingTimeInterval(secondsPerDay * 2)] {
            for index in 0...3 {
                let lift = Lift(context: moc)
                lift.reps = 10 + Int16(index)
                lift.sets = 1
                lift.notes = "Middle\nHigh Outside"
                lift.weight = 20
                lift.id = UUID()
                lift.timestamp = date
                lifts.append(lift)
            }
        }
        exercise.lifts = NSOrderedSet(array: lifts)
        return NavigationView {
            OlderLifts(exercise: exercise, dateSelected: .constant(Date()), managedObjectContext: moc)
        }.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
