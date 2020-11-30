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
    static var daySelected: DateComponents?
    @State var isPresented = false
    private static let title = "Calendar"
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                LiftsCalendarView(lifts: lifts.lifts) { day in
                    RootCalendarView.daySelected = day.components
                    isPresented.toggle()
                }
                .background(Color.blue)
                .frame(minHeight: LiftsCalendarView.minHeight)
                .listRowInsets(EdgeInsets(top: 0.0, leading: -SwiftUI.List.separatorInset, bottom: 0.0, trailing: 0.0))
            }
        }
        .navigationTitle(RootCalendarView.title)
        .sheet(isPresented: $isPresented) {
            LiftsOnDate(daySelected: RootCalendarView.daySelected)
        }
    }
}

struct ContentView: View {
    private static let title = "Exercises"
    
    let viewType: RootView.ViewType

    private var searchHidden: Bool = true
    
    @State var daySelected: DateComponents?
    @State private var query: String = ""
    
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
