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
import StoreKit

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
    
    @State var viewType: ViewType = .list
    @State var settingsVisible: Bool = false
    @State var announcementsToDisplay: [UserFeatureMessaging.Feature] = []
    
    func didAcknowledge(feature: UserFeatureMessaging.Feature) {
        announcementsToDisplay.removeAll { found in
            found == feature
        }
    }
    
    @Environment(\.requestReview) var requestReview
    
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
        .if(announcementsToDisplay.contains(.siri)) { view in
            view.overlay {
                SiriGuideView(didAcknowledge: didAcknowledge)
            }
        }
        .onAppear {
            let _ = UserFeatureMessaging.shared
        }
        .onReceive(UserFeatureMessaging.shared) { feature in
            announcementsToDisplay.append(feature)
            if feature == .appReview {
                requestReview()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        Group {
            RootView()
                .previewDisplayName("Light")
            RootView()
                .colorScheme(.dark)
                .previewDisplayName("Dark")
            RootView(viewType: .calendar)
            RootView(viewType: .calendar)
                .environment(\.colorScheme, ColorScheme.dark)
        }.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
