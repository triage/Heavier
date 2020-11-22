//
//  ListView.swift
//  Overload
//
//  Created by Eric Schulte on 10/27/20.
//

import Foundation
import SwiftUI

struct ListView: View {
    @Environment(\.managedObjectContext) var context

    let query: String
    let fetchRequest: FetchRequest<Exercise>
    
    var exercises: FetchedResults<Exercise> {
        return fetchRequest.wrappedValue
    }
    
    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    private func cell(exercise: Exercise) -> some View {
        VStack(alignment: .leading) {
            Text(exercise.name!)
                .sfCompactDisplay(.medium, size: 22.0)
            if let last = exercise.lifts?.lastObject as? Lift, let timestamp = last.timestamp {
                Text(ListView.timestampFormatter.string(from: timestamp))
            }
        }
        .padding(.vertical, 12)
    }
    
    private func cell(name: String) -> some View {
        NavigationLink(
            destination:
                ExerciseView(exercise: Exercise(name: name))
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
    
    var body: some View {
        List {
            if !exercises.isEmpty {
                ForEach(exercises) { exercise in
                    NavigationLink(destination: ExerciseView(exercise: exercise)) {
                        cell(exercise: exercise)
                    }
                }
            } else {
                cell(name: query)
            }
        }.listStyle(PlainListStyle())
    }
}


struct ListView_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        Group {
            ListView(
                query: "Romanian",
                fetchRequest: Exercise.searchFetchRequest(query: "Exercise")).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            ListView(
                query: "Romanian",
                fetchRequest: Exercise.searchFetchRequest(query: "Romanian")).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
