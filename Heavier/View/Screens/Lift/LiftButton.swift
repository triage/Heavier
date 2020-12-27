//
//  LiftButton.swift
//  Heavier
//
//  Created by Eric Schulte on 12/27/20.
//

import Foundation
import SwiftUI

struct LiftButton: View {
    
    let text: String
    let imageName: String
    let selected: Bool
    let imageNameTrailing: String?
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: imageName)
                Text(text)
                    .sfCompactDisplay(.medium, size: Theme.Font.Size.medium)
                    .foregroundColor(.liftDateForeground)
                if let imageNameTrailing = imageNameTrailing {
                    Image(systemName: imageNameTrailing)
                }
            }
            .padding(Theme.Spacing.smallPlus)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Spacing.large)
                    .stroke(Color.liftButtonBorderSelected, lineWidth: selected ? 3.0 : 0.0)
            )
        }
        .background(Color(Color.Overload.liftDateBackground.rawValue))
        .cornerRadius(Theme.Spacing.large)
        .padding([.bottom], Theme.Spacing.medium)
        .padding([.leading], Theme.Spacing.small)
        .accentColor(Color.accent)
        .labelsHidden()
        .foregroundColor(Color.liftDateForeground)
        .background(Color.clear)
    }
}

struct LiftButtonPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                LiftButton(
                    text: "Button",
                    imageName: "calendar",
                    selected: false,
                    imageNameTrailing: nil
                )
                
                LiftButton(
                    text: "Button",
                    imageName: "note.text",
                    selected: true,
                    imageNameTrailing: nil
                )
            }
            
            NavigationView {
                VStack {
                    LiftButton(
                        text: "Button",
                        imageName: "calendar",
                        selected: false,
                        imageNameTrailing: nil
                    )
                    
                    LiftButton(
                        text: "Button",
                        imageName: "note.text",
                        selected: true,
                        imageNameTrailing: "checkmark.circle.fill"
                    )
                }
            }
            .environment(\.colorScheme, ColorScheme.dark)
        }
    }
}
