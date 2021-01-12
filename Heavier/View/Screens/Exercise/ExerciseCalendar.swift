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

struct ExerciseCalendar: View {
    static let screenWidth = UIScreen.main.bounds.width
    
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
