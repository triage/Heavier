//
//  ContentView.swift
//  Overload
//
//  Created by Eric Schulte on 9/22/20.
//

import SwiftUI
import CoreData
import SwiftlySearch

struct ContentView: View {
    @State private var query: String = ""
    @State var isAddVisible = false
    
    var body: some View {
        NavigationView {
            ListView(
                query: query,
                fetchRequest: Exercise.searchFetchRequest(query: query))
                .navigationBarSearch($query)
            .navigationBarItems(
                leading:
                    Text("Exercises").font(.title),
                trailing:
                    Button(action: { }) {
                        Image(systemName: "calendar")
                    })
            .sheet(
                isPresented: $isAddVisible,
                content: {
                    DetailView(isPresented: $isAddVisible)
                }
            )
        }.edgesIgnoringSafeArea([.top, .bottom])
    }
}

struct ContentView_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        Group {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
