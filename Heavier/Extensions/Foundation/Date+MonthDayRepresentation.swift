//
//  Date+MonthDayRepresentation.swift
//  Heavier
//
//  Created by Eric Schulte on 12/5/24.
//

import Foundation

extension Date {
    private static var monthDateDateFormat: String {
        // Combine month and ordinal day
        // Example: "2nd January" or "January 2nd" depending on Locale
        return DateFormatter.dateFormat(fromTemplate: "MMMMd", options: 0, locale: Locale.current) ?? "MMMM d"
    }

    /*
     Some locales use "2nd January" and some use "January 2nd"
     */
    var localizedMonthDayRepresentation: String? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: self)
        
        // Extract month and day as Int
        guard let month = components.month, let day = components.day else {
            return nil
        }
        
        // Get the month name
        let monthName = DateFormatter.Heaver.monthNameFormatter.monthSymbols[month - 1] // Adjust for 0-based index
         
        let ordinalDay = NumberFormatter.Heavier.ordinalDayFormatter.string(from: NSNumber(value: day)) ?? "\(day)"
         
         // Combine month and ordinal day
         let localizedFormat = DateFormatter.dateFormat(fromTemplate: "MMMMd", options: 0, locale: Locale.current) ?? "MMMM d"
         if localizedFormat.contains("dMMMM") {
             return String(localized: "\(ordinalDay) of \(monthName)") // e.g., "2nd January"
         } else {
             return String(localized: "\(monthName) \(ordinalDay)") // e.g., "January 2nd"
         }
    }
}
