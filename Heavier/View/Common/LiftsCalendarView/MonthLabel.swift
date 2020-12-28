//
//  MonthLabel.swift
//  Heavier
//
//  Created by Eric Schulte on 12/27/20.
//

import Foundation
import SwiftUI
import HorizonCalendar
import CoreText
import UIKit

struct MonthLabel: CalendarItemViewRepresentable {
    struct InvariantViewProperties: Hashable {}
    
    private static let font = UIFont.sfDisplay(variation: .regular, size: Theme.Font.Size.large)
    
    struct ViewModel: Equatable {
        let month: Month
        var text: String {
            return "\(Calendar.current.monthSymbols[month.month - 1]) - \(month.year)"
        }
    }
    
    static func makeView(withInvariantViewProperties invariantViewProperties: InvariantViewProperties) -> UILabel {
        let label = UILabel()
        label.textColor = Color.calendarMonth.uiColor
        label.font = MonthLabel.font
        return label
    }
    
    static func setViewModel(_ viewModel: ViewModel, on view: UILabel) {
        view.text = viewModel.text
        view.setMargins(margin: SwiftUI.List.separatorInset)
    }
}
