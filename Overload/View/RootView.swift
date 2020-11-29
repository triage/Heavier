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
    private static let title = "Calendar"
    
    var body: some View {
        List {
            LiftsCalendarView(lifts: lifts.lifts) { day in
                daySelected = day.components
            }
            .background(Color.blue)
            .frame(minHeight: LiftsCalendarView.minHeight)
            .listRowInsets(EdgeInsets(top: 0.0, leading: -10.0, bottom :0.0, trailing: 0.0))
            
            LiftsOnDate(daySelected: daySelected)
                .listRowInsets(EdgeInsets(top: 0.0, leading: 10.0, bottom :0.0, trailing: 0.0))
        }
        .listStyle(PlainListStyle())
        .navigationTitle(RootCalendarView.title)
    }
}

struct ContentView: View {
    let viewType: RootView.ViewType

    private static let title = "Exercises"
    @State var daySelected: DateComponents?
    @State private var query: String = ""
    private var searchHidden: Bool = true
    
    init(viewType: RootView.ViewType) {
        self.viewType = viewType
        searchHidden = viewType == .calendar
    }
    
    var body: some View {
        if viewType == .calendar {
            RootCalendarView()
                .navigationBarSearch($query, isHidden: true)
        } else {
            ListView(
                query: query,
                fetchRequest: Exercise.searchFetchRequest(query: query)
            )
            .navigationTitle(ContentView.title)
            .navigationBarSearch($query, isHidden: searchHidden)
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
        }
        .edgesIgnoringSafeArea([.top, .bottom])
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
