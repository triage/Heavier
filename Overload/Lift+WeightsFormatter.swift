//
//  Lift+Formatter.swift
//  Overload
//
//  Created by Eric Schulte on 10/30/20.
//

import Foundation

extension Lift {
    static var weightsFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        numberFormatter.usesSignificantDigits = false
        return numberFormatter
    }
}
