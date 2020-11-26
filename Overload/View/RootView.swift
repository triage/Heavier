//
//  ContentView.swift
//  Overload
//
//  Created by Eric Schulte on 9/22/20.
//

import SwiftUI
import CoreData
import SwiftlySearch

struct RootView: View {
    @State private var query: String = ""
    @State var isAddVisible = false
    @State var viewType: ContentView.ViewType = .list
    
    var body: some View {
        NavigationView {
            ContentView(
                viewType: viewType,
                query: query,
                fetchRequest: Exercise.searchFetchRequest(query: query),
                liftFetchRequest: Lift.searchFetchRequest(query: query)
            )
            .navigationBarSearch($query)
            .navigationBarItems(
                leading:
                    Text("Exercises").font(.title),
                trailing:
                    Button(action: {
                        viewType.toggle()
                    }) {
                        viewType.toggled().icon
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

struct RootView_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        Group {
            RootView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            RootView(viewType: .calendar).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
