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
    private static let title = "Exercises"
    
    let viewType: RootView.ViewType

    private var searchHidden: Bool = true
    
    @Environment(\.managedObjectContext) var context
    
    @State var daySelected: DateComponents?
    @State private var query: String = ""
    
    init(viewType: RootView.ViewType) {
        self.viewType = viewType
        searchHidden = viewType == .calendar
    }
    
    var body: some View {
        if viewType == .calendar {
            RootCalendarView(context: context)
                .navigationBarSearch($query, isHidden: true)
        } else {
            ListView(
                query: query,
                fetchRequest: Exercise.CoreData.search(query)
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
    @State var settingsVisible: Bool = false
    
    var body: some View {
        NavigationView {
            ContentView(viewType: viewType)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            viewType.toggle()
                        }) {
                            viewType.toggled().icon
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            settingsVisible.toggle()
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                }
        }
        .accentColor(.accent)
        .edgesIgnoringSafeArea([.top, .bottom])
        .sheet(isPresented: $settingsVisible, content: {
            SettingsView()
        })
    }
}

struct RootView_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        Group {
            RootView()
            RootView(viewType: .calendar)
            RootView(viewType: .calendar)
                .environment(\.colorScheme, ColorScheme.dark)
        }.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
