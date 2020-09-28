//
//  ExerciseView.swift
//  Overload
//
//  Created by Eric Schulte on 9/27/20.
//

import Foundation
import SwiftUI

struct ExerciseView: View {
    var exercise: Exercise
    var body: some View {
        Text("hi").navigationTitle(exercise.name!)
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        let exercise = Exercise(context: PersistenceController.shared.container.viewContext)
        exercise.name = "Romanian Deadlift"
        exercise.id = UUID()
        return Group {
            NavigationView {
                ExerciseView(
                    exercise: exercise
                )
            }
        }
    }
}
