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
    @State var presented = false
    @State var lift: Lift?
    
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
        
        List {
            ForEach(lifts.lifts, id: \.id) { lift in
                Group {
                    Button(action: {
                        self.lift = lift
                        self.presented = true
                    }, label: {
                        Text(lift.shortDescription(units: Settings.shared.units))
                            .sfCompactDisplay(.regular, size: Theme.Font.Size.large)
                            .padding(
                                EdgeInsets(
                                    top: Theme.Spacing.medium,
                                    leading: 0.0,
                                    bottom: Theme.Spacing.medium,
                                    trailing: 0.0
                                )
                            )
                            .frame(
                                minWidth: 0.0,
                                idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/,
                                maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,
                                minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/,
                                idealHeight: 50,
                                maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,
                                alignment: .leading
                            )
                    })
                }
            }
        }.navigationTitle(title)
        .listStyle(PlainListStyle())
        .sheet(item: $lift) { item in
            LiftView(exercise: exercise, lift: item, presented: $presented, mode: .editing)
        }
    }
    
    struct ExerciseOnDate_Previews: PreviewProvider {
        
        static var previews: some View {
            Settings.shared.units = .metric
            
            let exercise = Exercise(context: PersistenceController.shared.container.viewContext)
            exercise.name = "Romanian Deadlift"
            exercise.id = UUID()
            var lifts = [Lift]()
            for index in 1...20 {
                let lift = Lift(context: PersistenceController.shared.container.viewContext)
                lift.reps = Int16(index)
                lift.sets = 4
                lift.notes = "Light weight, baby!"
                lift.weight = 20
                lift.id = UUID()
                lift.timestamp = Date()
                lifts.append(lift)
            }
            exercise.lifts = NSOrderedSet(array: lifts)
            
            return Group {
                NavigationView {
                    ExerciseOnDate(
                        exercise: exercise,
                        date: Date()
                    )
                }
            }
        }
    }
}
