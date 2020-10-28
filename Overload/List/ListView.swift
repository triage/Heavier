//
//  ListView.swift
//  Overload
//
//  Created by Eric Schulte on 10/27/20.
//

import Foundation
import SwiftUI

struct ListView: View {
    @Environment(\.managedObjectContext)
    var context

    let fetchRequest: FetchRequest<Exercise>
    
    var exercises: FetchedResults<Exercise> {
        return fetchRequest.wrappedValue
    }
    
    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        List {
            ForEach(exercises) { exercise in
                NavigationLink(destination: ExerciseView(exercise: exercise)) {
                    VStack(alignment: .leading) {
                        Text(exercise.name!)
                            .sfCompactDisplay(.medium, size: 22.0)
                        if let last = exercise.lifts?.lastObject as? Lift, let timestamp = last.timestamp {
                            Text(ListView.timestampFormatter.string(from: timestamp))
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
        }.listStyle(PlainListStyle())
    }
}


struct ListView_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        Group {
            ListView(fetchRequest: Exercise.searchFetchRequest(query: "Exercise")).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
