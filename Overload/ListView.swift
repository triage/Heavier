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
    
//    private let itemFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .medium
//        return formatter
//    }()
    
    var body: some View {
        List {
            ForEach(exercises) { exercise in
                NavigationLink(destination: ExerciseView(exercise: exercise)) {
                        Text(exercise.name!)
                            .sfCompactDisplay(size: 18.0)
                            .padding(.vertical, 12)
                }
            }
        }.listStyle(PlainListStyle())
    }
}
