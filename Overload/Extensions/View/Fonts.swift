//
//  Fonts.swift
//  Overload
//
//  Created by Eric Schulte on 10/26/20.
//

import Foundation
import SwiftUI

extension View {
    func sfCompactDisplay(_ variation: Theme.Font.SFCompactDisplay.Variation, size: CGFloat) -> some View {
        modifier(Theme.Font.SFCompactDisplay(variation: variation, size: size))
    }
}

class Theme {
    enum Font {
        struct SFCompactDisplay: ViewModifier {
            enum Variation: String {
                case regular = "SF Compact Display Regular"
                case medium = "SF Compact Display Medium"
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
        VStack {
            Text("A Quick Brown Fox Jumps Over the Lazy Dog (Regular)\n")
                .sfCompactDisplay(.regular, size: 30.0)
            Text("A Quick Brown Fox Jumps Over the Lazy Dog (Medium)")
                .sfCompactDisplay(.medium, size: 30.0)
        }.padding(20.0)
    }
}

