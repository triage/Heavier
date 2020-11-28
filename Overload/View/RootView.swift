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
    let viewType: RootView.ViewType
    let lifts: [Lift]
    
    @Binding var query: String
    var body: some View {
        if viewType == .calendar {
            LiftsCalendarView(lifts: lifts)
        } else {
            ListView(
                query: query,
                fetchRequest: Exercise.searchFetchRequest(query: query)
            )
            .navigationBarSearch($query)
        }
    }
}

struct RootView: View {

    enum ViewType {
        case list
        case calendar
        
        var icon: Image {
            if self == .calendar {
                return Image(systemName: "calendar")
            } else {
                return Image(systemName: "list.dash")
            }
        }
        
        func toggled() -> ViewType {
            return self == .calendar ? .list : .calendar
        }
        
        mutating func toggle() {
            if self == .calendar {
                self = .list
            } else {
                self = .calendar
            }
        }
    }
    
    @State private var query: String = ""
    @State var isAddVisible = false
    @State var viewType: ViewType = .list
    @ObservedObject var lifts = LiftsObservable(exercise: nil)
    
    var body: some View {
        NavigationView {
            ContentView(viewType: viewType, lifts: lifts.lifts, query: $query)
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
