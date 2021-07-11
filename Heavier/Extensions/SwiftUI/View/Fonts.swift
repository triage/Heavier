//
//  Fonts.swift
//  Overload
//
//  Created by Eric Schulte on 10/26/20.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    func sfCompactDisplay(_ variation: Theme.Font.SFCompactDisplay.Variation, size: CGFloat) -> some View {
        modifier(Theme.Font.SFCompactDisplay(variation: variation, size: UIFontMetrics.default.scaledValue(for: size)))
    }
}

extension UIFont {
    static func sfDisplay(variation: Theme.Font.SFCompactDisplay.Variation, size: CGFloat) -> UIFont {
        if let font = UIFont(name: variation.rawValue, size: UIFontMetrics.default.scaledValue(for: size)) {
            return font
        }
        return UIFont.preferredFont(forTextStyle: variation.textStyle)
    }
    
}

class Theme {
    enum Spacing {
        static let small: CGFloat = 4.0
        static let smallPlus: CGFloat = 8.0
        static let medium: CGFloat = 12.0
        static let mediumPlus: CGFloat = 18.0
        static let large: CGFloat = 20.0
        static let giga: CGFloat = 24.0
        static let edgesDefault: CGFloat = 20.0
    }
    
    enum Font {
        
        enum Size {
            static let small: CGFloat = 8.0
            static let medium: CGFloat = 12.0
            static let mediumPlus: CGFloat = 18.0
            static let large: CGFloat = 24.0
            static let giga: CGFloat = 54.0
        }
        
        struct SFCompactDisplay: ViewModifier {
            enum Variation: String {
                case regular = "SF Compact Display Regular"
                case medium = "SF Compact Display Medium"
                case bold = "SF Compact Display Bold"
                case black = "SF Compact Display Black"
                
                var textStyle: UIFont.TextStyle {
                    #if APPCLIP
                    switch self {
                    case .regular:
                        return .body
                    case .bold:
                        return .callout
                    default:
                        return .body
                    }
                    #else
                    switch self {
                    case .regular:
                        return .body
                    case .black:
                        return .headline
                    case .bold:
                        return .callout
                    case .medium:
                        return .subheadline
                    }
                    #endif
                }
            }
            let variation: Variation
            let size: CGFloat
            
            func body(content: Content) -> some View {
                content
                    .font(.custom(variation.rawValue, size: size))
            }            
        }
    }
}

struct Font_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        VStack(alignment: .leading) {
            Text("A Quick Brown Fox Jumps Over the Lazy Dog (Regular)")
                .sfCompactDisplay(.regular, size: 30.0)
                .padding([.bottom], 20.0)
            Text("A Quick Brown Fox Jumps Over the Lazy Dog (Medium)")
                .sfCompactDisplay(.medium, size: 30.0)
                .padding([.bottom], 20.0)
            Text("A Quick Brown Fox Jumps Over the Lazy Dog (Bold)")
                .sfCompactDisplay(.bold, size: 30.0)
                .padding([.bottom], 20.0)
            Text("A Quick Brown Fox Jumps Over the Lazy Dog (Black)")
                .sfCompactDisplay(.black, size: 30.0)
                .padding([.bottom], 20.0)
        }
    }
}
