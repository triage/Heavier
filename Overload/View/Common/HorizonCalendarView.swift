//
//  HorizonView.swift
//  Overload
//
//  Created by Eric Schulte on 11/24/20.
//

import Foundation
import SwiftUI
import HorizonCalendar

struct HorizonCalendarView: UIViewRepresentable {
    
    let lifts: [Lift]
    
    func makeUIView(context: Context) -> CalendarView {
        return CalendarView(initialContent: makeContent())
    }

    func updateUIView(_ uiView: CalendarView, context: UIViewRepresentableContext<HorizonCalendarView>) {
        
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
        )
    }
}
