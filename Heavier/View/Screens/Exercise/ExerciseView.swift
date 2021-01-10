//
//  ExerciseView.swift
//  Overload
//
//  Created by Eric Schulte on 9/27/20.
//

import Foundation
import SwiftUI
import CoreData
import SwiftUITrackableScrollView

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
    @State private var floatCalendar = true
    @State private var calendarYOffset: CGFloat = 0.0
    @State private var calendaryUnderlayOpacity: Double = 1.0
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
        if floatCalendar {
            withAnimation(.easeInOut(duration: ExerciseView.animationDuration)) {
                floatCalendar.toggle()
                calendaryUnderlayOpacity = 0.0
                showCalendarButton.toggle()
            }
        }
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
                   
                    Group {
                        Spacer()
                    }
                    .frame(
                        width: ExerciseCalendar.screenWidth,
                        height: LiftsCalendarView.frameHeight
                    )
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.blue)
                    .offset(x: 0, y: scrollViewContentOffset)
                    .clipped()
                    .shadow(
                        color: Color.black.opacity(floatCalendar ? 0.12 : 0.0),
                        radius: 3.0, x: 0.0, y: 3.0
                    ).blur(radius: 10.0)
                    
                    ExerciseCalendar(
                        sections: months.sections,
                        page: $page,
                        dateSelected: $dateSelected
                    )
                    .offset(x: Theme.Spacing.large, y: calendarOffset)
                    
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
