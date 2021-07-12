//
//  Date+Month.swift
//  Heavier
//
//  Created by Eric Schulte on 7/11/21.
//

import Foundation

extension Date {
    var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)!.start
    }
    
    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth)!
    }
}
