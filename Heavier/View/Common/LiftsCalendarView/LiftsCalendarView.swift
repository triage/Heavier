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

struct MonthLabel: CalendarItemViewRepresentable {
    struct InvariantViewProperties: Hashable {}
    
    private static let font = UIFont.sfDisplay(variation: .regular, size: Theme.Font.Size.large)
    
    struct ViewModel: Equatable {
        let month: Month
        var text: String {
            return "\(Calendar.current.monthSymbols[month.month - 1]) - \(month.year)"
        }
    }
    
    static func makeView(withInvariantViewProperties invariantViewProperties: InvariantViewProperties) -> UILabel {
        let label = UILabel()
        label.textColor = Color.calendarMonth.uiColor
        label.font = MonthLabel.font
        return label
    }
    
    static func setViewModel(_ viewModel: ViewModel, on view: UILabel) {
        view.text = viewModel.text
        view.setMargins(margin: SwiftUI.List.separatorInset)
    }
}

struct DayLabel: CalendarItemViewRepresentable {
    
    /// Properties that are set once when we initialize the view.
    struct InvariantViewProperties: Hashable {
    }
    
    private static let fontDefault = UIFont.sfDisplay(variation: .regular, size: Theme.Font.Size.mediumPlus)
    private static let fontHasLifts = UIFont.sfDisplay(variation: .medium, size: Theme.Font.Size.mediumPlus)
    
    /// Properties that will vary depending on the particular date being displayed.
    struct ViewModel: Equatable {
        let lifts: [Lift]?
        let day: Day
        
        private var hasLifts: Bool {
            guard let count = lifts?.count else {
                return false
            }
            return count > 0
        }
        
        var font: UIFont {
            hasLifts ? DayLabel.fontHasLifts : DayLabel.fontDefault
        }
        
        var textColor: UIColor {
            hasLifts ? Color.calendarDayLifts.uiColor : Color.calendarDayDefault.uiColor
        }
        
        var text: String {
            "\(day.day)"
        }
        
        var borderColor: UIColor {
            hasLifts ? Color.calendarDayLifts.uiColor : UIColor.clear
        }
        
        var borderWidth: CGFloat = 2.0
    }
    
    final class DayView: UILabel {
        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = bounds.size.width / 2.0
        }
    }
    
    static func makeView(withInvariantViewProperties invariantViewProperties: InvariantViewProperties) -> DayView {
        let label = DayView(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }
    
    static func setViewModel(_ viewModel: ViewModel, on view: DayView) {
        view.text = viewModel.text
        view.font = viewModel.font
        view.textColor = viewModel.textColor
        view.layer.borderColor = viewModel.borderColor.cgColor
        view.layer.borderWidth = viewModel.borderWidth
    }
}

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
