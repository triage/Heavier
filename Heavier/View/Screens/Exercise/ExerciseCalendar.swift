//
//  ExerciseCalendar.swift
//  Heavier
//
//  Created by Eric Schulte on 1/10/21.
//

import Foundation
import SwiftUI
import HorizonCalendar
import SwiftUIPager

struct ExerciseCalendar: View, Equatable {
    static func == (lhs: ExerciseCalendar, rhs: ExerciseCalendar) -> Bool {
        let equal = lhs.lifts == rhs.lifts
        print("equal:\(equal)")
        return equal
    }
    
    static let screenWidth = UIScreen.main.bounds.width
    
    private static let layoutMargin = UIEdgeInsets(
        top: 0.0,
        left: 20.0,
        bottom: 0.0,
        right: 0.0
    )
    
    @Binding var lifts: [Lift]
    
    @Binding var dateSelected: Date?
    
    var body: some View {
        print("new exercise calendar")
        return Group {
            LiftsCalendarView(
                lifts: $lifts,
                timestampBounds: lifts.timestampBoundsMonths,
                monthsLayout: .horizontal(options:
                                            HorizontalMonthsLayoutOptions(
                                                maximumFullyVisibleMonths: 1,
                                                scrollingBehavior: .paginatedScrolling(
                                                    HorizontalMonthsLayoutOptions.PaginationConfiguration(
                                                        restingPosition: .atIncrementsOfCalendarWidth,
                                                        restingAffinity: .atPositionsClosestToTargetOffset
                                                    )
                                                )
                                            )
                ),
                onDateSelect: { (day) in
                    var components = day.components
                    // why is day always missing calendar?
                    // without this, date is nil
                    components.calendar = Calendar.autoupdatingCurrent
                    dateSelected = components.date
                }
            ).frame(
                width: ExerciseCalendar.screenWidth,
                height: LiftsCalendarView.frameHeight
            )
        }
        .background(Color.blue)
        .frame(
            width: ExerciseCalendar.screenWidth,
            height: LiftsCalendarView.frameHeight
        )
    }
}

struct ExerciseCalendar_Previews: PreviewProvider {
    
    @State static var dateSelected: Date? = Date()
    
    static var previews: some View {
        Settings.shared.units = .metric
        
        let exercise = Exercise(context: PersistenceController.shared.container.viewContext)
        exercise.name = "Romanian Deadlift"
        exercise.id = UUID()
        var lifts = [Lift]()
        let secondsPerDay: TimeInterval = 60 * 60 * 24
        for date in [Date(), Date().addingTimeInterval(secondsPerDay), Date().addingTimeInterval(secondsPerDay * 60)] {
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
        
        return Group {
            NavigationView {
//                ExerciseCalendar(
//                    lifts: exercise.lifts!.array as! [Lift],
//                    dateSelected: $dateSelected
//                )
            }
        }
    }
}
