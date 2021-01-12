//
//  Lift+Bounds.swift
//  Heavier
//
//  Created by Eric Schulte on 1/2/21.
//

import Foundation

extension Array where Element == Lift {
    var timestampBounds: ClosedRange<Date>? {
        guard let first = first?.timestamp, let last = last?.timestamp else {
            return nil
        }
        return first...last
    }
}
