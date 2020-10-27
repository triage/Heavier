//
//  Fonts.swift
//  Overload
//
//  Created by Eric Schulte on 10/26/20.
//

import Foundation
import SwiftUI

extension View {
    func sfCompactDisplay(size: CGFloat) -> some View {
        for family: String in UIFont.familyNames
        {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
        return modifier(Theme.Font.SFCompactDisplay(size: size))
    }
}

private class Theme {
    enum Font {
        struct SFCompactDisplay: ViewModifier {
            let size: CGFloat
            
            func body(content: Content) -> some View {
                content
                    .font(.custom("SF Compact Display Regular", size: size))
            }
        }
    }
}


struct Font_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        Group {
            Text("A Quick Brown Fox Jumps Over the Lazy Dog")
                .sfCompactDisplay(size: 30.0)
        }
    }
}

