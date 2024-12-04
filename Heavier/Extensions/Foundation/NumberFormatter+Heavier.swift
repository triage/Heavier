//
//  NumberFormatter+Weight.swift
//  Heavier
//
//  Created by Eric Schulte on 12/3/24.
//

import Foundation

extension NumberFormatter {
    enum Heavier {
        static var weightFormatter: NumberFormatter {
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 0
            numberFormatter.usesGroupingSeparator = true
            return numberFormatter
        }
        
        static var ordinalDayFormatter: NumberFormatter {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .ordinal
            numberFormatter.locale = Locale.current
            return numberFormatter
        }
    }
}
