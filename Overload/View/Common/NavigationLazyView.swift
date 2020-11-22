//
//  NavigationLazyView.swift
//  Overload
//
//  Created by Eric Schulte on 11/21/20.
//

import Foundation
import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
