//
//  ContentView.swift
//  Overload
//
//  Created by Eric Schulte on 9/22/20.
//

import SwiftUI
import CoreData
import SwiftlySearch

struct RootCalendarView: View {
    @ObservedObject var lifts = LiftsObservable(exercise: nil)
    @State var daySelected: DateComponents?
    
    var body: some View {
        List {
            LiftsCalendarView(lifts: lifts.lifts) { day in
                daySelected = day.components
            }.frame(minHeight: LiftsCalendarView.minHeight)
            
            LiftsOnDate(daySelected: daySelected)
        }.listStyle(PlainListStyle())
    }
}

struct ContentView: View {
    let viewType: RootView.ViewType

    @State var daySelected: DateComponents?
    @State private var query: String = ""
    
    var body: some View {
        if viewType == .calendar {
            RootCalendarView()
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
    
    @State var isAddVisible = false
    @State var viewType: ViewType = .list
    
    var body: some View {
        NavigationView {
            ContentView(viewType: viewType)
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
            RootView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            RootView(viewType: .calendar)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            RootView(viewType: .calendar)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environment(\.colorScheme, ColorScheme.dark)
        }
    }
}
