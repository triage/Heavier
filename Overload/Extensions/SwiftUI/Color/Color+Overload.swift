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
        case calendarDay_default
        case calendarDay_lifts
        case calendarMonth
    }
    
    private init(_ overload: Overload) {
        self.init(overload.rawValue)
    }
    
    static let highlight = Color(.highlight)
    static let underline = Color(.underline)
    static let label = Color(.label)
    static let calendarDay_default = Color(.calendarDay_default)
    static let calendarDay_lifts = Color(.calendarDay_lifts)
    static let calendarMonth = Color(.calendarMonth)
    
    var uiColor: UIColor {
        UIColor(self)
    }
}
