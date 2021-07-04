//
//  ExerciseOnDate.swift
//  Heavier
//
//  Created by Eric Schulte on 7/4/21.
//

import Foundation
import SwiftUI

struct ExerciseOnDate: View {
    let exercise: Exercise
    let date: Date
    @StateObject private var lifts: LiftsObservable
    
    init(exercise: Exercise, date: Date) {
        self.exercise = exercise
        self.date = date
        _lifts = .init(
            wrappedValue: LiftsObservable(
                exercise: exercise,
                dateComponents: Calendar.autoupdatingCurrent.dateComponents(
                    [.day, .month, .year],
                    from: date
                )
            )
        )
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter
    }
    
    var title: String {
        guard let name = exercise.name else {
            fatalError("exercise without name")
        }
        return "\(name) - \(ExerciseOnDate.dateFormatter.string(from: date))"
    }
    
    var body: some View {
        LazyVStack(content: {
            ForEach(lifts.lifts, id: \.id) { lift in
                Text(lift.shortDescription(units: Settings.shared.units))
            }
        })
        .navigationTitle(title)
    }
}

struct ExerciseOnDate_Previews: PreviewProvider {
    
    static var previews: some View {
        Settings.shared.units = .metric
        
        let exercise = Exercise(context: PersistenceController.shared.container.viewContext)
        exercise.name = "Romanian Deadlift"
        exercise.id = UUID()
        var lifts = [Lift]()
        let secondsPerDay: TimeInterval = 60 * 60 * 24
        for date in [Date(), Date().addingTimeInterval(secondsPerDay), Date().addingTimeInterval(secondsPerDay * 60)] {
            for _ in 0...2 {
                let lift = Lift(context: PersistenceController.shared.container.viewContext)
                lift.reps = 10
                lift.sets = 1
                lift.notes = "Light weight, baby!"
                lift.weight = 20
                lift.id = UUID()
                lift.timestamp = date
                lifts.append(lift)
            }
        }
        exercise.lifts = NSOrderedSet(array: lifts)
        
        return Group {
            NavigationView {
                ExerciseView(
                    exercise: exercise
                )
            }
        }
    }
}
