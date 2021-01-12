//
//  CalendarButton.swift
//  Heavier
//
//  Created by Eric Schulte on 1/11/21.
//

import Foundation
import SwiftUI

struct CalendarButton: View {
    let onPress: () -> Void
    var body: some View {
        Button(action: onPress, label: {
            Group {
                Image(systemName: "calendar")
            }.padding(17.0)
            .background(Color.background.opacity(0.4))
            .overlay(
                Circle()
                    .strokeBorder(lineWidth: 2.0)
            ).mask(Circle())
        })
    }
}

struct CalendarButtonPreview: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(alignment: .center) {
                Spacer()
                HStack(alignment: .center) {
                    Spacer()
                    CalendarButton {}
                    Spacer()
                }.background(Color.blue)
                Spacer()
            }.background(Color.blue)
        }
    }
}
