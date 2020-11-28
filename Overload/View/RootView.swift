//
//  ContentView.swift
//  Overload
//
//  Created by Eric Schulte on 9/22/20.
//

import SwiftUI
import CoreData
import SwiftlySearch

struct LiftsOnDate: View {
    let fetchRequest: FetchRequest<Lift>
    var lifts: FetchedResults<Lift> {
        return fetchRequest.wrappedValue
    }
    
    var exercises: [String: [Lift]]? {
        return Dictionary(grouping: lifts) { (lift: Lift) -> String in
            return lift.exercise!.name!
        }
    }
    
    var body: some View {
        OlderLifts(lifts: Array(lifts))
    }
}

struct ContentView: View {
    let viewType: RootView.ViewType
    let lifts: [Lift]
    
    @Binding var query: String
    @State var daySelected: DateComponents?
    var body: some View {
        if viewType == .calendar {
            List {
                LiftsCalendarView(lifts: lifts) { day in
                    daySelected = day.components
                }.frame(minHeight: LiftsCalendarView.minHeight)
                if let daySelected = daySelected, let fetchRequest = Lift.fetchRequest(day: daySelected) {
                    LiftsOnDate(fetchRequest: FetchRequest(fetchRequest: fetchRequest))
                }
            }.listStyle(PlainListStyle())
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
