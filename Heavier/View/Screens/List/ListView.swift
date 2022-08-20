//
//  ListView.swift
//  Overload
//
//  Created by Eric Schulte on 10/27/20.
//

import Foundation
import SwiftUI

struct ListView: View {

    let query: String
    let fetchRequest: FetchRequest<Exercise>
    
    @State var exerciseSelected: Exercise?
    @State var isPresenting = false
    @ObservedObject var settings = Settings.shared
    
    var exercises: FetchedResults<Exercise> {
        return fetchRequest.wrappedValue
    }
    
    static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    private struct LiftShortDescription: View {
        let group: [Lift]
        let settings: Settings
        var body: some View {
            VStack(alignment: .leading) {
                if let shortDescription = group.shortDescription(units: settings.units) {
                    Text(shortDescription)
                }
                if let timestamp = group.first?.timestamp {
                    Text(ListView.timestampFormatter.string(from: timestamp))
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                        .padding([.top], 2.0)
                }
            }
        }
    }
    
    private func cell(name: String) -> some View {
        NavigationLink(
            destination:
                NavigationLazyView(
                    ExerciseView(exercise: Exercise(name: name, relevance: Exercise.Relevance.maximum, context: PersistenceController.scrapContext))
                )
        ) {
            HStack {
                Text(name)
                    .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                Spacer()
                Image(systemName: "plus.circle")
                    .font(.system(size: Theme.Font.Size.large))
            }
            .padding(.vertical, Theme.Spacing.medium)
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
        VStack {
            NavigationLink(
                destination: ExerciseView(exercise: exerciseSelected),
                isActive: $isPresenting,
                label: {
                    EmptyView()
                })
            List {
                ForEach(rows, id: \.hashValue) { row in
                    if let exercise = row as? Exercise {
                        ExerciseCell(
                            exerciseSelected: $exerciseSelected,
                            isPresenting: $isPresenting,
                            exercise: exercise
                        ).id(exercise.listViewIdentifier)
                    } else if let name = row as? String {
                        cell(name: name)
                            .id(name)
                    } else {
                        EmptyView()
                    }
                }
            }.listStyle(PlainListStyle())
        }
    }
}

private extension Exercise {
    var listViewIdentifier: String {
        if let name = name, let timestamp = timestamp {
            return "\(name) - \(timestamp.timeIntervalSince1970)"
        }
        return ""
    }
}

struct ExerciseCell: View {
    @Binding var exerciseSelected: Exercise?
    @Binding var isPresenting: Bool
    
    @ObservedObject var exercise: Exercise
    @ObservedObject var settings = Settings.shared
    
    private struct LiftShortDescription: View {
        let lifts: [Lift]
        let settings: Settings
        var body: some View {
            VStack(alignment: .leading) {
                if let shortDescription = lifts.shortDescription(units: settings.units) {
                    Text(shortDescription)
                }
                if let timestamp = lifts.first?.timestamp {
                    Text(ListView.timestampFormatter.string(from: timestamp))
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                        .padding([.top], 2.0)
                }
            }
        }
    }
    
    var body: some View {
        
        Button(action: {
            self.exerciseSelected = exercise
            self.isPresenting = true
        }, label: {
            HStack(alignment: .top, spacing: nil, content: {
                VStack(alignment: .leading) {
                    Text(exercise.name!)
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                    if let lastGroup = exercise.lastGroup {
                        LiftShortDescription(lifts: lastGroup, settings: settings)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: Theme.Font.Size.large))
                    .opacity(0.25)
                    .scaleEffect(0.5)
            })
            .padding(.vertical, Theme.Spacing.medium)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        Group {
            ListView(
                query: "Romanian",
                fetchRequest: Exercise.CoreData.search("Exercise")
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            ListView(
                query: "Romanian",
                fetchRequest: Exercise.CoreData.search("Romanian")
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
