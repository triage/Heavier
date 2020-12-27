//
//  NotesView.swift
//  Heavier
//
//  Created by Eric Schulte on 12/26/20.
//

import Foundation
import SwiftUI

struct NotesView: View {
    
    @Binding var notes: String
    @Binding var isPresented: Bool
    
    let placeholders = [
        "It doesn't get easier. You just get stronger.",
        "Go deeper.",
        "The pain you feel today will be the strength you feel tomorrow",
        "It it doesn't challenge you, it doesn't change you",
        "No excuses",
        "Body under construction. Mind on a mission"
    ]
    
    @State var placeholder: String
    
    init?(notes: Binding<String>, isPresented: Binding<Bool>) {
        _notes = notes
        _isPresented = isPresented
        guard let placeholder = placeholders.randomElement() else {
            return nil
        }
        _placeholder = .init(wrappedValue: placeholder)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .topLeading) {
                    TextView(becomeFirstResponder: true, text: $notes)
                        .backgroundColor(UIColor.clear)
                        .padding(Theme.Spacing.medium)
                        .alignmentGuide(.top, computeValue: { dimension in
                            dimension[.top]
                        })
                    if let placeholder = placeholder, notes.count == 0 {
                        Text(placeholder)
                            .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                            .padding(Theme.Spacing.medium)
                            .padding([.leading, .top], Theme.Spacing.smallPlus)
                            .foregroundColor(.placeholder)
                    }
                }
                Spacer()
            }
            .navigationTitle("Notes")
            .navigationBarItems(
                trailing:
                    Button(action: {
                        isPresented.toggle()
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
        NotesView(notes: .constant(""), isPresented: .constant(false))
    }
}
