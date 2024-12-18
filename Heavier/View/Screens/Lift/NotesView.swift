//
//  NotesView.swift
//  Heavier
//
//  Created by Eric Schulte on 12/26/20.
//

import Foundation
import SwiftUI

struct NotesView: View {
    
    // bound to the parent view
    @Binding var notes: String
    
    // input on this view. Not "committed" till user taps navigation item.
    @State var text: String
    
    let onSave: () -> Void
    
    let placeholders = [
        String(localized: "It doesn't get easier. You just get stronger"),
        String(localized: "The pain you feel today will be the strength you feel tomorrow"),
        String(localized: "If it doesn't challenge you, it doesn't change you"),
        String(localized: "No excuses"),
        String(localized: "Body under construction. Mind on a mission"),
        String(localized: "If you cheat, you only cheat yourself"),
        String(localized: "Don't be afraid to fail. Be afraid not to try"),
        String(localized: "Biceps don't grow on trees")
    ]
    
    @State var placeholder: String
    
    init?(notes: Binding<String>, onSave: @escaping () -> Void) {
        _notes = notes
        _text = .init(wrappedValue: notes.wrappedValue)
        self.onSave = onSave
        guard let placeholder = placeholders.randomElement() else {
            return nil
        }
        _placeholder = .init(wrappedValue: placeholder)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .topLeading) {
                    TextView(becomeFirstResponder: true, text: $text)
                        .backgroundColor(UIColor.clear)
                        .padding(Theme.Spacing.medium)
                        .alignmentGuide(.top, computeValue: { dimension in
                            dimension[.top]
                        })
                    if text.count == 0 {
                        Text(placeholder)
                            .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                            .padding(Theme.Spacing.medium)
                            .padding([.top], Theme.Spacing.smallPlus)
                            .padding([.leading], Theme.Spacing.smallPlus - 2.0)
                            .foregroundColor(Color(.placeholder))
                    }
                }
                Spacer()
            }
            .navigationTitle("Notes")
            .navigationBarItems(
                trailing:
                    Button(action: {
                        notes = text
                        onSave()
                    }, label: {
                        Image(systemName: "checkmark.circle")
                            .sfCompactDisplay(.bold, size: Theme.Font.Size.large)
                    })
            )
        }
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView(notes: .constant(""), onSave: {})
    }
}
