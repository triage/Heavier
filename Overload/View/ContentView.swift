//
//  ListView.swift
//  Overload
//
//  Created by Eric Schulte on 10/27/20.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var context

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
    
    let viewType: ViewType
    let query: String
    let fetchRequest: FetchRequest<Exercise>
    let liftFetchRequest: FetchRequest<Lift>
    
    var exercises: FetchedResults<Exercise> {
        return fetchRequest.wrappedValue
    }
    var lifts: FetchedResults<Lift> {
        return liftFetchRequest.wrappedValue
    }
    
    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    private static func liftShortDescription(lift: Lift) -> some View {
        VStack(alignment: .leading) {
            Text(lift.shortDescription)
            if let timestamp = lift.timestamp {
                Text(ContentView.timestampFormatter.string(from: timestamp))
                    .sfCompactDisplay(.regular, size: 12.0)
                    .padding(EdgeInsets(top: 2.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
            }
        }
    }
    
    private func cell(exercise: Exercise) -> some View {
        NavigationLink(
            destination:
                NavigationLazyView(
                    ExerciseView(exercise: exercise)
                )
        ) {
            VStack(alignment: .leading) {
                Text(exercise.name!)
                    .sfCompactDisplay(.medium, size: 22.0)
                if let lastLift = exercise.lastLift {
                    ContentView.liftShortDescription(lift: lastLift)
                }
            }
            .padding(.vertical, 12)
        }
    }
    
    private func cell(name: String) -> some View {
        NavigationLink(
            destination:
                NavigationLazyView(
                    ExerciseView(exercise: Exercise(name: name))
                )
        ) {
            HStack {
                Text(name)
                    .sfCompactDisplay(.medium, size: 22.0)
                Spacer()
                Image(systemName: "plus.circle")
                    .font(.system(size: 24))
            }
            .padding(.vertical, 12)
        }
    }
    
    var rows: [AnyHashable] {
        /*
         If there's a direct match, show that one first, followed by the others
         If there's not a direct match and the query length is > 0, show the "add new" cell, followed by the others
         Else, show all the exercises
         */
        var rows: [AnyHashable] = Array(self.exercises).sorted {
            if $0.lastLiftDate != nil && $1.lastLift == nil {
                return true
            } else if $0.lastLiftDate == nil && $0.lastLiftDate != nil {
                return false
            }
            guard let first = $0.lastLiftDate, let second = $1.lastLiftDate else {
                return false
            }
            return first > second
        }
        if let directMatch: Exercise = exercises.first(where: { (exercise) -> Bool in
            exercise.name?.lowercased() == query.lowercased()
        }), let index = rows.firstIndex(of: directMatch) {
            // Found a direct match. Move it to first position.
            rows.move(fromOffsets: IndexSet(integer: index), toOffset: 0)
        } else if query.count > 0 {
            rows.insert(query, at: 0)
        }
        return rows
    }
    
    var body: some View {
        if viewType == .list {
            List {
                ForEach(rows, id: \.self) { row in
                    if let exercise = row as? Exercise {
                        cell(exercise: exercise)
                    } else if let name = row as? String {
                        cell(name: name)
                    } else {
                        EmptyView()
                    }
                }
            }.listStyle(PlainListStyle())
        } else {
            HorizonCalendarView(lifts: Array(lifts))
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        Group {
            ContentView(
                viewType: .list,
                query: "Romanian",
                fetchRequest: Exercise.searchFetchRequest(query: "Exercise"),
                liftFetchRequest: Lift.searchFetchRequest(query: "Exercise")
            )
                
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            ContentView(
                viewType: .calendar,
                query: "Romanian",
                fetchRequest: Exercise.searchFetchRequest(query: "Romanian"),
                liftFetchRequest: Lift.searchFetchRequest(query: "Exercise")
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
