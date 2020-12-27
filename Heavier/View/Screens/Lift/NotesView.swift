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
    
    var body: some View {
        NavigationView {
            VStack {
                TextView(becomeFirstResponder: true, text: $notes)
                    .backgroundColor(UIColor.clear)
                    .padding(Theme.Spacing.medium)
                    .alignmentGuide(.top, computeValue: { dimension in
                        dimension[.top]
                    })
                Spacer()
            }.navigationBarItems(
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
        NotesView(notes: .constant("Hello World"), isPresented: .constant(false))
    }
}
