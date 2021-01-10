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
                    proxy.scrollTo(sectionId, anchor: .top)
                }
            })
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
    @Binding var dateSelected: Date?
    
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
                            var components = day.components
                            // why is day always missing calendar?
                            // without this, date is nil
                            components.calendar = Calendar.autoupdatingCurrent
                            dateSelected = components.date
                        }
                    ).offset(x: -ExerciseCalendar.layoutMargin.left)
                  }
            )
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
        .background(Color.background)
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
    let onPress: () -> Void
    var body: some View {
        Button(action: onPress, label: {
            Group {
                Image(systemName: "calendar")
            }.padding(17.0)
            .background(Color.background)
            .overlay(
                Circle()
                    .strokeBorder(lineWidth: 2.0)
            )
        })
    }
}

struct ExerciseView: View {
    let exercise: Exercise
    
    @State private var liftViewPresented = false
    @State private var page: Int
    @State private var scrollViewContentOffset: CGFloat = 0.0
    @State private var showCalendarButton = false
    @State private var floatCalendar = false
    @State private var calendarYOffset: CGFloat = 0.0
    @State private var calendaryUnderlayOpacity: Double = 0.0
    @State private var dateSelected: Date?
    
    @StateObject private var lifts: LiftsObservable
    @StateObject private var months: LiftsObservable
    
    private static let showCalendarButtonAtScrollOffset: CGFloat = 390.0
    private static let animationDuration: TimeInterval = 0.24
    
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
    
    private func onScroll(value: CGFloat) {
        if floatCalendar {
            withAnimation(.easeIn(duration: ExerciseView.animationDuration)) {
                floatCalendar.toggle()
                calendaryUnderlayOpacity = 0.0
                if showCalendarButton == false {
                    showCalendarButton.toggle()
                }
            }
            return
        }
        if value > ExerciseView.showCalendarButtonAtScrollOffset && !showCalendarButton {
            withAnimation(.easeOut(duration: ExerciseView.animationDuration)) {
                showCalendarButton.toggle()
            }
        } else if value < ExerciseView.showCalendarButtonAtScrollOffset && showCalendarButton {
            withAnimation(.easeIn(duration: ExerciseView.animationDuration)) {
                showCalendarButton.toggle()
            }
        }
    }
    
    private func showCalendar() {
        withAnimation(.easeInOut(duration: ExerciseView.animationDuration)) {
            floatCalendar.toggle()
            calendaryUnderlayOpacity = 1.0
        }
    }
    
    private struct CalendarUnderlay: View {
        let visible: Bool
        var body: some View {
            if visible {
                Group {
                    Text("")
                }
                .disabled(true)
                .fillScreen()
                .background(Color.overlay)
                .edgesIgnoringSafeArea(.all)
            } else {
                EmptyView()
            }
        }
    }
    
    func onTapUnderlay() {
        withAnimation(.easeInOut(duration: ExerciseView.animationDuration)) {
            floatCalendar.toggle()
            calendaryUnderlayOpacity = 0.0
            showCalendarButton.toggle()
        }
    }
    
    func onDateChanged(date: Date?) {
        onTapUnderlay()
    }
    
    var calendarOffset: CGFloat {
        if floatCalendar {
            return scrollViewContentOffset
        } else {
            return scrollViewContentOffset > LiftsCalendarView.frameHeight ?
                scrollViewContentOffset - LiftsCalendarView.calendarHeight : 0.0
        }
    }
    
    var body: some View {
        TrackableScrollView(.vertical, showIndicators: false, contentOffset: $scrollViewContentOffset) {
            ZStack(alignment: .topLeading) {
                if lifts.lifts.count > 0 {
                    
                    OlderLifts(
                        sections: lifts.sections,
                        dateSelected: dateSelected
                    )
                    .padding([.leading], Theme.Spacing.large)
                    
                    CalendarUnderlay(visible: floatCalendar)
                        .opacity(calendaryUnderlayOpacity)
                        .offset(x: 0.0, y: scrollViewContentOffset)
                        .onTapGesture {
                            onTapUnderlay()
                        }

                    ExerciseCalendar(
                        sections: months.sections,
                        page: $page,
                        dateSelected: $dateSelected
                    )
                    .offset(x: Theme.Spacing.large, y: calendarOffset)
//                    .shadow(
//                        color: Color.black.opacity(floatCalendar ? 0.12 : 0.0),
//                        radius: 3.0, x: 0.0, y: 3.0
//                    )
                    
                } else {
                    Text("No lifts recorded yet.")
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.mediumPlus)
                }
            }
        }
        .onChange(of: dateSelected, perform: onDateChanged)
        .onChange(of: scrollViewContentOffset, perform: onScroll)
        .overlay(
            CalendarButton {
                showCalendarButton.toggle()
                showCalendar()
            }
            .opacity(showCalendarButton ? 1.0 : 0.0)
            .offset(x: -20, y: showCalendarButton ? 30 : -50), alignment: .topTrailing)
        
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
