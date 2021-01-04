//
//  ExerciseView.swift
//  Overload
//
//  Created by Eric Schulte on 9/27/20.
//

import Foundation
import SwiftUI
import CoreData
import HorizonCalendar
import SwiftUIPager
import SwiftUITrackableScrollView

struct OlderLifts: View {
    private let sections: [NSFetchedResultsSectionInfo]
    
    init?(sections: [NSFetchedResultsSectionInfo]?) {
        guard let sections = sections else {
            return nil
        }
        self.sections = sections
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
            }   
        }
    }
}

struct RecentLiftMetric: View {
    let value: CustomStringConvertible
    let label: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(value.description)
                .sfCompactDisplay(.medium, size: 44.0)
                .minimumScaleFactor(0.2)
                .lineLimit(0)
            Text(label)
                .sfCompactDisplay(.medium, size: Theme.Font.Size.medium)
                .lineLimit(0)
                .padding([.top], -Theme.Spacing.medium)
        }
    }
}

struct RecentLift: View {
    let lift: Lift?
    
    var volume: String? {
        guard let lift = lift, let localized = Lift.localize(weight: lift.volume) else {
            return nil
        }
        let number = NSNumber(value: localized)
        return Lift.weightsFormatter.string(from: number)
    }
    
    var body: some View {
        if let lift = lift, let volume = volume {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("most recent lift:")
                            .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                        Text(MostRecentLift.lastLiftDateFormatter.string(from: lift.timestamp!))
                            .sfCompactDisplay(.bold, size: Theme.Font.Size.mediumPlus)
                    }
                }.padding([.bottom], Theme.Spacing.small)
                
                HStack(spacing: Theme.Spacing.giga) {
                    RecentLiftMetric(value: lift.sets, label: "sets")
                    RecentLiftMetric(value: lift.reps, label: "reps")
                    if !lift.isBodyweight {
                        RecentLiftMetric(
                            value: Lift.weightsFormatter.string(from: NSNumber(value: lift.weightLocalized.weight))!,
                            label: "weight (\(Settings.shared.units.label))"
                        )
                    }
                    Spacer()
                }
                if !lift.isBodyweight {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(volume)
                                .sfCompactDisplay(.medium, size: Theme.Font.Size.giga)
                                .minimumScaleFactor(1.0)
                                .lineLimit(1)
                            Text("total volume (\(Settings.shared.units.label))")
                                .sfCompactDisplay(.medium, size: Theme.Font.Size.medium)
                        }
                    }
                }
                
                if let notes = lift.notes, notes.count > 0 {
                    Text(notes)
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.mediumPlus)
                        .padding([.top], Theme.Spacing.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], Theme.Spacing.large)
        } else {
            EmptyView()
        }
    }
}

struct ExerciseCalendar: View {
    private static let screenWidth = UIScreen.main.bounds.width
    
    private static let layoutMargin = UIEdgeInsets(
        top: 0.0,
        left: 10.0,
        bottom: 0.0,
        right: 10.0
    )
    
    let sections: [LiftsSection]
    
    @Binding var page: Int
    
    var body: some View {
        Group {
            Pager(page: $page,
                  data: sections,
                  id: \.name,
                  content: { section in
                    LiftsCalendarView(
                        lifts: section.lifts!,
                        timestampBounds: section.lifts?.timestampBounds,
                        monthsLayout: MonthsLayout.horizontal(
                            monthWidth: ExerciseCalendar.screenWidth - Theme.Spacing.edgesDefault
                        ),
                        onDateSelect: { (day) in
                            print("hi")
                        }
                    ).offset(x: -ExerciseCalendar.layoutMargin.left)
                  }
            )
            .expandPageToEdges()
            .preferredItemSize(
                CGSize(
                    width: ExerciseCalendar.screenWidth,
                    height: LiftsCalendarView.calendarHeight
                )
            )
            .frame(
                width: ExerciseCalendar.screenWidth,
                height: LiftsCalendarView.calendarHeight
            )
        }
        .padding([.top], Theme.Spacing.smallPlus)
        .frame(
            width: ExerciseCalendar.screenWidth,
            height: LiftsCalendarView.frameHeight
        )
        .clipped()
        .offset(x: -ExerciseCalendar.layoutMargin.horizontal, y: 0.0)
    }
}

struct CalendarButton: View {
    var body: some View {
        Group {
            Image(systemName: "calendar")
        }
    }
}

struct ExerciseView: View {
    let exercise: Exercise
    @State var liftViewPresented = false
    @State var page: Int
    @StateObject var lifts: LiftsObservable
    @StateObject var months: LiftsObservable
    
    init?(exercise: Exercise?) {
        guard let exercise = exercise else {
            return nil
        }
        self.exercise = exercise
        
        _lifts = .init(
            wrappedValue: LiftsObservable(exercise: exercise, ascending: false)
        )
        
        let monthsObservable = LiftsObservable(
            exercise: exercise,
            ascending: true,
            sectionNameKeyPath: #keyPath(Lift.monthGroupingIdentifier)
        )
        _months = .init(
            wrappedValue:
                monthsObservable
        )
        _page = .init(initialValue: monthsObservable.sections.count - 1)
    }
    
    @State private var scrollViewContentOffset: CGFloat = 0.0
    
    // RecentLift(lift: lifts.lifts.first)
    var body: some View {
        ZStack(alignment: .topLeading) {
            TrackableScrollView(.vertical, showIndicators: false, contentOffset: $scrollViewContentOffset) {
                if lifts.lifts.count > 0 {
                    LazyVStack(alignment: .leading) {
                            OlderLifts(sections: lifts.sections)
                                .padding([.top], LiftsCalendarView.frameHeight)
                                .padding([.leading], Theme.Spacing.large)
                        }
                } else {
                    Text("No lifts recorded yet.")
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.mediumPlus)
                }
            }
            
            ExerciseCalendar(sections: months.sections, page: $page)
                .offset(x: 20.0, y: -scrollViewContentOffset)
            
            CalendarButton()
        }
        .navigationTitle(exercise.name!)
        .toolbar(
            content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        liftViewPresented = true
                    }, label: {
                        Image(systemName: "plus")
                            .font(.system(size: Theme.Font.Size.large))
                    })
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    // This is stupid. If I don't put this here, after
                    // saving a new item to the context, the back button
                    // disappears. Possible Apple bug.
                    Text("")
                }
            }
        ).sheet(isPresented: $liftViewPresented) {
            LiftView(exercise: exercise, lift: lifts.lifts.first, presented: $liftViewPresented)
        }
    }
}

struct ExerciseView_Previews: PreviewProvider {
    
    static var previews: some View {
        Settings.shared.units = .metric
        
        let exercise = Exercise(context: PersistenceController.shared.container.viewContext)
        exercise.name = "Romanian Deadlift"
        exercise.id = UUID()
        var lifts = [Lift]()
        for _ in 0...39 {
            let lift = Lift(context: PersistenceController.shared.container.viewContext)
            lift.reps = 10
            lift.sets = 1
            lift.notes = "Light weight, baby!"
            lift.weight = 20
            lift.id = UUID()
            lift.timestamp = Date(timeIntervalSince1970: 1608508800)
            lifts.append(lift)
        }
        exercise.lifts = NSOrderedSet(array: lifts)
        
        let exerciseNoLifts = Exercise(context: PersistenceController.shared.container.viewContext)
        exerciseNoLifts.name = "Romanian Deadlift"
        exerciseNoLifts.id = UUID()
        
        let exerciseBodyweight = Exercise(context: PersistenceController.shared.container.viewContext)
        exerciseBodyweight.name = "Romanian Deadlift"
        exerciseBodyweight.id = UUID()
        
        lifts.removeAll()
        for _ in 0...2 {
            let lift = Lift(context: PersistenceController.shared.container.viewContext)
            lift.reps = 10
            lift.sets = 2
            lift.weight = 0
            lift.id = UUID()
            lift.timestamp = Date()
            lifts.append(lift)
        }
        exerciseBodyweight.lifts = NSOrderedSet(array: lifts)
        
        return Group {
            NavigationView {
                ExerciseView(
                    exercise: exercise
                )
            }
//            NavigationView {
//                ExerciseView(
//                    exercise: exerciseNoLifts
//                )
//            }
//            NavigationView {
//                ExerciseView(
//                    exercise: exerciseBodyweight
//                )
//            }
        }
    }
}
