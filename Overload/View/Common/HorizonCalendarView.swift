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

struct DayLabel: CalendarItemViewRepresentable {
    
    /// Properties that are set once when we initialize the view.
    struct InvariantViewProperties: Hashable {
        let textColor: UIColor
        let backgroundColor: UIColor
    }
    
    static let font = UIFont.sfDisplay(variation: .regular, fontSize: 18.0)
    
    /// Properties that will vary depending on the particular date being displayed.
    struct ViewModel: Equatable {
        let lifts: [Lift]?
        let day: Day
    }
    
    static func makeView(
        withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> UILabel
    {
        let label = UILabel()
        
        label.backgroundColor = invariantViewProperties.backgroundColor
        label.font = font
        label.textColor = invariantViewProperties.textColor
        label.textAlignment = .center
        label.clipsToBounds = true
        
        return label
    }
    
    static func setViewModel(_ viewModel: ViewModel, on view: UILabel) {
        view.text = "\(viewModel.day.day)"
        if let count = viewModel.lifts?.count, count > 0 {
            view.textColor = UIColor.red
        } else {
            view.textColor = UIColor.lightGray
        }
    }
    
}

struct HorizonCalendarView: UIViewRepresentable {
    
    let lifts: [Lift]
    
    func makeUIView(context: Context) -> CalendarView {
        CalendarView(initialContent: makeContent())
    }
    
    func updateUIView(_ uiView: CalendarView, context: UIViewRepresentableContext<HorizonCalendarView>) {
        
    }
    
    private static var groupingDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }
    
    var days: [String: [Lift]] {
        Dictionary(grouping: lifts) { (lift) -> String in
            HorizonCalendarView.groupingDateFormatter.string(from: lift.timestamp!)
        }
    }
    
    private func makeContent() -> CalendarViewContent {
        let date = Date()
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        let startDate = calendar.date(from: DateComponents(year: components.year, month: components.month, day: 1))!
        let endDate = calendar.date(byAdding: DateComponents(calendar: calendar, month: 1), to: startDate)!
        
        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions())
        ).withDayItemModelProvider { day in
            CalendarItemModel<DayLabel>(
                invariantViewProperties: .init(
                    textColor: .darkGray,
                    backgroundColor: .clear),
                viewModel: .init(lifts: days[day.description], day: day))
        }
    }
}
