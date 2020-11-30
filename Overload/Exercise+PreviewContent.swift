//
//  Exercise+PreviewContent.swift
//  Overload
//
//  Created by Eric Schulte on 11/27/20.
//

import Foundation

extension Exercise {
    enum Preview {
        static var preview: Exercise {
            let exercise = Exercise(context: PersistenceController.shared.container.viewContext)
            exercise.name = "Romanian Deadlift"
            exercise.id = UUID()
            
            let range = 60 * 60 * 24 * 30
            
            var lifts = [Lift]()
            for iterator in 0...20 {
                let lift = Lift(context: PersistenceController.shared.container.viewContext)
                lift.reps = 10
                lift.sets = Int16(iterator + 10)
                lift.weight = 100
                lift.id = UUID()
                lift.timestamp = Date().addingTimeInterval(Double(Int.random(in: -range...range)))
                lifts.append(lift)
            }
            
            exercise.lifts = NSOrderedSet(array: lifts)
            return exercise
        }
    }
}
