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
    
    private let lifts: [Lift]
    private let days: [String: [Lift]]
    private let onDateSelect: DaySelectionhandler
    private let monthsLayout: MonthsLayout
    private let timestampBounds: ClosedRange<Date>?
    
    /*
     The height we must supply as the height of the calendar.
     Anything less than this results in a crash.
     */
    static let calendarHeight: CGFloat = 420
    /*
     The maximum height the calendar will _actually_ be.
     This is the height that we should clip to.
     */
    static let frameHeight: CGFloat = 410
    private static let groupingDateFormat = "yyyy-MM-dd"
    
    init(
        lifts: [Lift],
        timestampBounds: ClosedRange<Date>? = nil,
        monthsLayout: MonthsLayout = MonthsLayout.vertical(options: VerticalMonthsLayoutOptions()),
        onDateSelect: @escaping DaySelectionhandler
    ) {
        self.lifts = lifts
        self.monthsLayout = monthsLayout
        self.onDateSelect = onDateSelect
        self.timestampBounds = timestampBounds
        self.days = Dictionary(grouping: lifts) { (lift) -> String in
            LiftsCalendarView.groupingDateFormatter.string(from: lift.timestamp!)
        }
    }
    
    private var shouldScrollToDate: Bool {
        let date = Date()
        if let timestampBounds = timestampBounds,
            date > timestampBounds.lowerBound &&
            date < timestampBounds.upperBound {
            return true
        }
        return false
    }
    
    func makeUIView(context: Context) -> CalendarView {
        let calendar = CalendarView(initialContent: makeContent())
        if shouldScrollToDate {
            calendar.scroll(toDayContaining: Date(), scrollPosition: .centered, animated: false)
        }
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
        dateFormatter.calendar = Calendar.autoupdatingCurrent
        dateFormatter.dateFormat = LiftsCalendarView.groupingDateFormat
        return dateFormatter
    }
    
    private func makeContent() -> CalendarViewContent {
        let calendar = Calendar(identifier: .gregorian)
        var calendarBounds: ClosedRange<Date>
        
        if let timestampBounds = timestampBounds {
            calendarBounds = timestampBounds
        } else {
            // default if there are no lifts yet - show current month
            
            let date = Date()
            let components = calendar.dateComponents([.day, .month, .year], from: date)
            let startDate = calendar.date(from: DateComponents(year: components.year, month: components.month, day: 1))!
            let endDate = calendar.date(byAdding: DateComponents(calendar: calendar, month: 1), to: startDate)!
            calendarBounds = startDate...endDate
            
            if calendarBounds.upperBound < Date() {
                calendarBounds = calendarBounds.lowerBound...Date()
            }
        }
        
        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: calendarBounds,
            monthsLayout: monthsLayout
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
