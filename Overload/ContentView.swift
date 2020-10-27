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
            ListView(fetchRequest: Exercise.searchFetchRequest(query: query))
            .navigationBarItems(
                leading:
                    SearchView(text: $query),
                trailing:
                    Button(action: { }) {
                        Image(systemName: "calendar")
                            .accentColor(.black)
                    })
            .accentColor(.black)
            .sheet(
                isPresented: $isAddVisible,
                content: {
                    DetailView(isPresented: $isAddVisible)
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        Group {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            DetailView(isPresented: .constant(false)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            SearchView(text: $text)
        }
    }
}
