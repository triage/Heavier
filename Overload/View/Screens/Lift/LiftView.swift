//
//  LiftView.swift
//  Overload
//
//  Created by Eric Schulte on 10/28/20.
//

import Foundation
import SwiftUI

struct LiftViewCloseButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: Theme.Font.Size.large, weight: .bold, design: .default))
                .accentColor(.highlight)
        }
    }
}

struct LiftView: View {
    let exercise: Exercise
    let lift: Lift?
    
    @State var reps: Float
    @State var sets: Float
    @State var weight: Float
    var presented: Binding<Bool>
    
    init(exercise: Exercise, lift: Lift?, presented: Binding<Bool>) {
        self.exercise = exercise
        self.lift = lift
        self.presented = presented
        _sets = .init(initialValue: Float(lift?.sets ?? 3))
        _reps = .init(initialValue: Float(lift?.reps ?? 10))
        _weight = .init(initialValue: Float(lift?.weight ?? 45))
    }
    
    var volume: Float {
        Float(Float(reps) * Float(sets) * weight)
    }
    
    func save() {
        let lift = Lift(context: PersistenceController.shared.container.viewContext)
        lift.reps = Int16(reps)
        lift.sets = Int16(sets)
        lift.weight = Float(weight)
        lift.id = UUID()
        lift.timestamp = Date()
        exercise.addToLifts(lift)
        do {
            try? PersistenceController.shared.container.viewContext.save()
            presented.wrappedValue.toggle()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 18.0) {
                MostRecentLift(lift: lift)
                LiftPicker(
                    label: "sets",
                    range: 1...20,
                    interval: 1,
                    value: $sets,
                    initialValue: Float(lift?.sets ?? 1)
                )
                LiftPicker(
                    label: "reps",
                    range: 1...20,
                    interval: 1,
                    value: $reps,
                    initialValue: Float(lift?.reps ?? 1)
                )
                LiftPicker(
                    label: "lbs",
                    range: 0...700,
                    interval: 5,
                    value: $weight,
                    initialValue: Float(lift?.weight ?? 1)
                )
                HStack(alignment: .lastTextBaseline, spacing: Theme.Spacing.medium) {
                    Text("= \(Lift.volumeFormatter.string(from: NSNumber(value: volume))!) lbs")
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.giga)
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                    DifferenceView(initialValue: lift?.volume, value: volume)
                        .offset(x: 0.0, y: -DifferenceView.padding.bottom)
                }
                
                Button(action: save, label: {
                    Text("Save")
                        .padding(Theme.Spacing.medium)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                }).background(Color.blue)
                .cornerRadius(Theme.Spacing.medium * 2.0)
                .padding([.top], Theme.Spacing.large)
                
                Spacer()
                
            }.padding([.top, .leading, .trailing], Theme.Spacing.large)
            .navigationTitle(exercise.name!)
        }
    }
}

struct LiftView_ContentPreviews: PreviewProvider {
    @State static var presented = true
    
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
            LiftView(exercise: exercise, lift: lift, presented: $presented)
            LiftView(exercise: exercise, lift: lift, presented: $presented)
            LiftView(exercise: exercise, lift: lift, presented: $presented)
                .environment(\.colorScheme, ColorScheme.dark)
        }
    }
}
