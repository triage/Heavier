//
//  BlackOverlay.swift
//  Heavier
//
//  Created by Eric Schulte on 1/11/21.
//

import Foundation
import SwiftUI

struct BlackOverlay: View {
    let visible: Bool
    var body: some View {
        if visible {
            Group {
                Text("")
            }
            .disabled(true)
            .fillScreen()
            .background(Color(.overlayBackground))
            .edgesIgnoringSafeArea(.all)
        } else {
            EmptyView()
        }
    }
}
