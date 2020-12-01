//
//  Lift+WillSave.swift
//  Overload
//
//  Created by Eric Schulte on 11/24/20.
//

import Foundation

extension Lift {
    static var dayFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }
    
    public override func willSave() {
        guard let timestamp = timestamp else {
            return
        }
        setPrimitiveValue(Lift.dayFormatter.string(from: timestamp), forKey: #keyPath(Lift.day))
    }
}
