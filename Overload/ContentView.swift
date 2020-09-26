//
//  ContentView.swift
//  Overload
//
//  Created by Eric Schulte on 9/22/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)],
        animation: .default)
    private var exercises: FetchedResults<Exercise>
    @State var isAddVisible = false

    var body: some View {
        NavigationView {
            List {
                ForEach(exercises) { exercise in
                    Text(exercise.name!)
                }
            }
            .navigationTitle("Exercises")
            .toolbar {
                Button(action: { isAddVisible.toggle() }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }.sheet(
            isPresented: $isAddVisible,
            content: {
                DetailView(isPresented: $isAddVisible).environment(\.managedObjectContext, viewContext)
            }
        ).accentColor(.red)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { exercises[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            DetailView(isPresented: .constant(false)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}

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
