//
//  DetailView.swift
//  Overload
//
//  Created by Eric Schulte on 10/27/20.
//

import Foundation
import SwiftUI

struct DetailView: View {
    @State var name: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    private static var nameMinLength = 2
    private func buttonClicked() {
        let exercise = Exercise(context: viewContext)
        exercise.name = name
        exercise.id = UUID()
        do {
            try viewContext.save()
            isPresented = false
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private var buttonDisabled: Bool {
        return name.count <= DetailView.nameMinLength
    }
    
    var body: some View {
        VStack {
            Text("Exercise name:")
            TextField("Name", text: $name)
            HStack(spacing: 20) {
                Button("Cancel", action: { isPresented.toggle() })
                Button("Done", action: buttonClicked).disabled(buttonDisabled)
            }
        }.padding(20)
    }
}
