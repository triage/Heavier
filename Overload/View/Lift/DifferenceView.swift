//
//  Difference.swift
//  Overload
//
//  Created by Eric Schulte on 10/31/20.
//

import Foundation
import SwiftUI

struct DifferenceView: View {
    let initialValue: Int?
    let value: Int
    
    static let padding = EdgeInsets(top: 5.0, leading: 10.0, bottom: 5.0, trailing: 10.0)
    
    private static var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.positivePrefix = "+"
        return numberFormatter
    }
    
    private var difference: String? {
        guard let initialValue = initialValue,
              let differenceValue = DifferenceView.numberFormatter.string(from: NSNumber(value: value - initialValue)) else {
            return nil
        }
        return "\(differenceValue) lbs"
    }
    
    var body: some View {
        if let initialValue = initialValue, initialValue != value, let difference = difference {
            Text(difference)
                .foregroundColor(.white)
                .padding(DifferenceView.padding)
                .background(Color.label)
                .cornerRadius(MostRecentLift.padding * 2.0)
        } else {
            EmptyView()
        }
    }
}
