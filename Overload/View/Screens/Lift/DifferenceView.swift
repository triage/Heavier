//
//  Difference.swift
//  Overload
//
//  Created by Eric Schulte on 10/31/20.
//

import Foundation
import SwiftUI

struct DifferenceView: View {
    let initialValue: Float?
    let value: Float
    
    static let padding = EdgeInsets(top: 5.0, leading: 10.0, bottom: 5.0, trailing: 10.0)
    
    private static var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.positivePrefix = "+"
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter
    }
    
    private var difference: String? {
        guard let initialValue = initialValue,
              let differenceValue = DifferenceView.numberFormatter.string(
                from: NSNumber(value: value - initialValue)
              ) else {
            return nil
        }
        return "\(differenceValue) \(Settings.shared.units.label)"
    }
    
    var body: some View {
        if let initialValue = initialValue, initialValue != value, let difference = difference {
            Text(difference)
                .foregroundColor(.differenceForeground)
                .padding(DifferenceView.padding)
                .background(Color.differenceBackground)
                .cornerRadius(MostRecentLift.padding * 2.0)
        } else {
            EmptyView()
        }
    }
}
