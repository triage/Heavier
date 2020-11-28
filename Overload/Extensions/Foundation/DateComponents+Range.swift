//
//  DateComponents+.swift
//  Overload
//
//  Created by Eric Schulte on 11/28/20.
//

import Foundation

extension DateComponents {
    var dayRange: ClosedRange<Date>? {
        var day = self
        day.calendar = Calendar.current
        guard
            let date = day.date,
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
                return nil
        }
        return Calendar.current.startOfDay(for: date)...endOfDay
    }
}
