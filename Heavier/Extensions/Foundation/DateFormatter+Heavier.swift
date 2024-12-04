//
//  DateFormatter+Heavier.swift
//  Heavier
//
//  Created by Eric Schulte on 12/3/24.
//

import Foundation

extension DateFormatter {
    enum Heaver {
        static var monthNameFormatter: DateFormatter {
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM"
            monthFormatter.locale = Locale.current
            return monthFormatter
        }
    }
}
