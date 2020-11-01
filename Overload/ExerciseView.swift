//
//  ExerciseView.swift
//  Overload
//
//  Created by Eric Schulte on 9/27/20.
//

import Foundation
import SwiftUI

struct ExerciseView: View {
    let exercise: Exercise?
    let name: String?
    @State var liftViewPresented = false
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self.name = nil
    }
    
    init(name: String) {
        self.name = name
        self.exercise = nil
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0.0) {
                MostRecentLift(lift: exercise?.lifts?.lastObject as? Lift)
            }.padding(20.0)
        }
        .navigationTitle(name ?? exercise!.name!)
        .navigationBarItems(trailing: Button(action: {
            liftViewPresented = true
        }, label: {
            Image(systemName: "plus")
                .font(.system(size: 24))
        })).sheet(isPresented: $liftViewPresented) {
            LiftView(lift: exercise?.lifts?.lastObject as? Lift, presented: $liftViewPresented)
        }
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        let exercise = Exercise(context: PersistenceController.shared.container.viewContext)
        exercise.name = "Romanian Deadlift"
        exercise.id = UUID()
        
        let lift = Lift(context: PersistenceController.shared.container.viewContext)
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
            NavigationView {
                ExerciseView(
                    name: "New Exercise"
                )
            }
        }
    }
}
