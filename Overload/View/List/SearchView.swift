//
//  SearchView.swift
//  Overload
//
//  Created by Eric Schulte on 10/27/20.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @Binding var text: String
    var body: some View {
        TextField("Exercise Name", text: $text)
            .sfCompactDisplay(.regular, size: Theme.Font.Size.large)
    }
}
