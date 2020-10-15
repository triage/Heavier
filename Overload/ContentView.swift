//
//  ContentView.swift
//  Overload
//
//  Created by Eric Schulte on 9/22/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var query: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var isAddVisible = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search", text: $query)
                    .padding(20.0)
                ListView(fetchRequest: Exercise.searchFetchRequest(query: query))
            }.hiddenNavigationBarStyle()
        }
        .hiddenNavigationBarStyle()
        .accentColor(.red)
        .sheet(
            isPresented: $isAddVisible,
            content: {
                DetailView(isPresented: $isAddVisible)
            }
        )
    }
}

struct ListView: View {
    @Environment(\.managedObjectContext)
    var context

    var fetchRequest: FetchRequest<Exercise>
    
    var exercises: FetchedResults<Exercise> {
        return fetchRequest.wrappedValue
    }
    
    var body: some View {
        List {
            ForEach(exercises) { exercise in
                NavigationLink(destination: ExerciseView(exercise: exercise)) {
                    Text(exercise.name!)
                }
            }
        }.listStyle(PlainListStyle())
    }
}

struct HiddenNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        content
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

extension View {
    func hiddenNavigationBarStyle() -> some View {
        modifier( HiddenNavigationBar() )
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
