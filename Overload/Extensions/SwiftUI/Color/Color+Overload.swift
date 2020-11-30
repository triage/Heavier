//
//  Color+Overload.swift
//  Overload
//
//  Created by Eric Schulte on 10/27/20.
//

import Foundation
import SwiftUI

extension Color {
    enum Overload: String {
        case highlight
        case underline
        case calendarDayDefault
        case calendarDayLifts
        case calendarMonth
    }
    private init(_ overload: Overload) {
        self.init(overload.rawValue)
    }
    static let highlight = Color(.highlight)
    static let underline = Color(.underline)
    static let label = Color(.label)
    static let calendarDayDefault = Color(.calendarDayDefault)
    static let calendarDayLifts = Color(.calendarDayLifts)
    static let calendarMonth = Color(.calendarMonth)
    var uiColor: UIColor {
        UIColor(self)
    }
}
