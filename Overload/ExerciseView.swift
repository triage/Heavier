//
//  ExerciseView.swift
//  Overload
//
//  Created by Eric Schulte on 9/27/20.
//

import Foundation
import SwiftUI

fileprivate extension Lift {
    private static var weightsFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        numberFormatter.usesSignificantDigits = false
        return numberFormatter
    }
    
    var shortDescription: String {
        "\(sets) x \(reps) @\(Lift.weightsFormatter.string(from: weight as NSNumber)!)"
    }
}

struct MostRecentLift: View {
    
    static var lastLiftDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter
    }
    
    let lifts: NSOrderedSet?
    static let padding: CGFloat = 14.0
    var body: some View {
        if let last = lifts?.lastObject as? Lift,
           let timestamp = last.timestamp {
            HStack {
                VStack(alignment: .leading) {
                    Text("most recent lift:")
                        .sfCompactDisplay(.regular, size: 10.0)
                    Text(last.shortDescription)
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
    let exercise: Exercise?
    let name: String?
    @State var modalVisible = false
    
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
                MostRecentLift(lifts: exercise?.lifts)
            }.padding(20.0)
        }
        .navigationTitle(name ?? exercise!.name!)
        .navigationBarItems(trailing: Button(action: {}, label: {
            Image(systemName: "plus")
                .font(.system(size: 24))
        }))
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
