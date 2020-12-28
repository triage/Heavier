//
//  DayLabel.swift
//  Heavier
//
//  Created by Eric Schulte on 12/27/20.
//

import Foundation
import SwiftUI
import HorizonCalendar
import UIKit

struct DayLabel: CalendarItemViewRepresentable {
    
    /// Properties that are set once when we initialize the view.
    struct InvariantViewProperties: Hashable {
    }
    
    private static let fontDefault = UIFont.sfDisplay(variation: .regular, size: Theme.Font.Size.mediumPlus)
    private static let fontHasLifts = UIFont.sfDisplay(variation: .medium, size: Theme.Font.Size.mediumPlus)
    
    /// Properties that will vary depending on the particular date being displayed.
    struct ViewModel: Equatable {
        let lifts: [Lift]?
        let day: Day
        
        private var hasLifts: Bool {
            guard let count = lifts?.count else {
                return false
            }
            return count > 0
        }
        
        var font: UIFont {
            hasLifts ? DayLabel.fontHasLifts : DayLabel.fontDefault
        }
        
        var textColor: UIColor {
            hasLifts ? Color.calendarDayLifts.uiColor : Color.calendarDayDefault.uiColor
        }
        
        var text: String {
            "\(day.day)"
        }
        
        var borderColor: UIColor {
            hasLifts ? Color.calendarDayLifts.uiColor : UIColor.clear
        }
        
        var borderWidth: CGFloat = 2.0
    }
    
    final class DayView: UILabel {
        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = bounds.size.width / 2.0
        }
    }
    
    static func makeView(withInvariantViewProperties invariantViewProperties: InvariantViewProperties) -> DayView {
        let label = DayView(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }
    
    static func setViewModel(_ viewModel: ViewModel, on view: DayView) {
        view.text = viewModel.text
        view.font = viewModel.font
        view.textColor = viewModel.textColor
        view.layer.borderColor = viewModel.borderColor.cgColor
        view.layer.borderWidth = viewModel.borderWidth
    }
}
