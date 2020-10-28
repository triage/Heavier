//
//  ExerciseView.swift
//  Overload
//
//  Created by Eric Schulte on 9/27/20.
//

import Foundation
import SwiftUI

struct MostRecentLift: View {
    
    static var lastLiftDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter
    }
    
    let lifts: NSOrderedSet
    static let padding: CGFloat = 14.0
    var body: some View {
        if let last = lifts.lastObject as? Lift,
           let timestamp = last.timestamp {
            HStack {
                VStack(alignment: .leading) {
                    Text("most recent lift:")
                        .sfCompactDisplay(.regular, size: 10.0)
                    Text("5 x 10 @185")
                        .sfCompactDisplay(.medium, size: 18.0)
                    Text(MostRecentLift.lastLiftDateFormatter.string(from: timestamp))
                        .sfCompactDisplay(.regular, size: 12.0)
                }
                    .padding(MostRecentLift.padding)
                    .background(Color.highlight)
                    .cornerRadius(MostRecentLift.padding * 2.0)
                Spacer()
            }
        } else {
            EmptyView()
        }
    }
}

struct ExerciseView: View {
    var exercise: Exercise
    var body: some View {
//        Text("asdf").navigationTitle(exercise.name!)
        ScrollView {
            VStack(alignment: .leading, spacing: 0.0) {
                MostRecentLift(lifts: exercise.lifts!)
            }.padding(20.0)
        }.navigationTitle(exercise.name!)
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        let exercise = Exercise(context: PersistenceController.shared.container.viewContext)
        exercise.name = "Romanian Deadlift"
        exercise.id = UUID()
        
        let lift = Lift()
        lift.reps = 10
        lift.sets = 3
        lift.weight = 135
        lift.id = UUID()
        lift.timestamp = Date()
        exercise.lifts = NSOrderedSet(object: lift)
        
        return Group {
            NavigationView {
                ExerciseView(
                    exercise: exercise
                )
            }
        }
    }
}
