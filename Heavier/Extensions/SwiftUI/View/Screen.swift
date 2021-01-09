//
//  Screen.swift
//  Heavier
//
//  Created by Eric Schulte on 1/9/21.
//

import Foundation
import SwiftUI

extension View {
    @inlinable public func fillScreen() -> some View {
        frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }
}
