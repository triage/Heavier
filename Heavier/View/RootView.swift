//
//  ContentView.swift
//  Overload
//
//  Created by Eric Schulte on 9/22/20.
//

import SwiftUI
import CoreData
import Combine
import AppIntents

struct ContentView: View {
    private static let title = "Exercises"
    
    let viewType: RootView.ViewType

    private var searchHidden: Bool = true
    
    @Environment(\.managedObjectContext) var context
    
    @State var daySelected: DateComponents?
    
    init(viewType: RootView.ViewType) {
        self.viewType = viewType
        searchHidden = viewType == .calendar
    }
    
    var body: some View {
        VStack {
            if viewType == .calendar {
                RootCalendarView(context: context)
            } else {
                ListView()
                    .navigationTitle(ContentView.title)
            }
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
    
    private static let siriAnnouncementKey = "didAcknowledgeSiriAnnouncement-1"
    
    @State var viewType: ViewType = .list
    @State var settingsVisible: Bool = false
    @State var didAcknowledgeSiriAnnouncement = UserDefaults.standard.bool(forKey: RootView.siriAnnouncementKey)
    
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
        .navigationViewStyle(.stack)
        .accentColor(Color(.accent))
        .edgesIgnoringSafeArea([.top, .bottom])
        .sheet(isPresented: $settingsVisible, content: {
            SettingsView()
        })
        .if(!didAcknowledgeSiriAnnouncement) { view in
            view.overlay {
                SiriGuideView(didAcknowledgeSiriAnnouncement: $didAcknowledgeSiriAnnouncement)
            }
        }
        .onChange(of: didAcknowledgeSiriAnnouncement) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: RootView.siriAnnouncementKey)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        Group {
            RootView(didAcknowledgeSiriAnnouncement: true)
                .previewDisplayName("Light")
            RootView(didAcknowledgeSiriAnnouncement: false)
                .colorScheme(.dark)
                .previewDisplayName("Dark")
            RootView(viewType: .calendar)
            RootView(viewType: .calendar)
                .environment(\.colorScheme, ColorScheme.dark)
        }.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
