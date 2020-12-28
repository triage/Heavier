//
//  HorizonView.swift
//  Overload
//
//  Created by Eric Schulte on 11/24/20.
//

import Foundation
import SwiftUI
import HorizonCalendar
import CoreText
import UIKit

struct LiftsCalendarView: UIViewRepresentable {
    
    typealias DaySelectionhandler = ((Day) -> Void)
    
    let lifts: [Lift]
    let onDateSelect: DaySelectionhandler
    
    static let minHeight: CGFloat = 420
    private static let groupingDateFormat = "YYYY-MM-dd"
    
    func makeUIView(context: Context) -> CalendarView {
        let calendar = CalendarView(initialContent: makeContent())
        calendar.scroll(toDayContaining: Date(), scrollPosition: .centered, animated: false)
        return calendar
    }
    
    class Coordinator: NSObject {
        let daySelectionHandler: DaySelectionhandler
        init(daySelectionHandler: @escaping DaySelectionhandler) {
            self.daySelectionHandler = daySelectionHandler
        }
    }
    
    func makeCoordinator() ->LiftsCalendarView.Coordinator {
        Coordinator(
            daySelectionHandler: onDateSelect
        )
    }
    
    func updateUIView(_ uiView: CalendarView, context: UIViewRepresentableContext<LiftsCalendarView>) {
        uiView.daySelectionHandler = context.coordinator.daySelectionHandler
    }
    
    private static var groupingDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = LiftsCalendarView.groupingDateFormat
        return dateFormatter
    }
    
    var days: [String: [Lift]] {
        Dictionary(grouping: lifts) { (lift) -> String in
            LiftsCalendarView.groupingDateFormatter.string(from: lift.timestamp!)
        }
    }
    
    private func makeContent() -> CalendarViewContent {
        let date = Date()
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        
        let calendarBounds: ClosedRange<Date>
        if let timestampBounds = Lift.timestampBounds {
            calendarBounds = timestampBounds
        } else {
            let startDate = calendar.date(from: DateComponents(year: components.year, month: components.month, day: 1))!
            let endDate = calendar.date(byAdding: DateComponents(calendar: calendar, month: 1), to: startDate)!
            calendarBounds = startDate...endDate
        }
        
        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: calendarBounds,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions())
        ).withDayItemModelProvider { day in
            CalendarItemModel<DayLabel>(
                invariantViewProperties: .init(),
                viewModel: .init(lifts: days[day.description], day: day))
        }.withMonthHeaderItemModelProvider { month in
            CalendarItemModel<MonthLabel>(
                invariantViewProperties: .init(),
                viewModel: .init(
                    month: month
                )
            )
        }.withInterMonthSpacing(50.0)
    }
}

struct LiftsCalendar_ContentPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            LiftsCalendarView(lifts: Exercise.Preview.preview.lifts!.array as! [Lift], onDateSelect: { day in
                print("day selected:\(day.description)")
            })
        }
    }
}
