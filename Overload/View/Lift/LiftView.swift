//
//  LiftView.swift
//  Overload
//
//  Created by Eric Schulte on 10/28/20.
//

import Foundation
import SwiftUI

struct LiftViewCloseButton: View {
    @Binding var presented: Bool
    var body: some View {
        Button(action: {
            withAnimation {
                presented.toggle()
            }
        }) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24.0, weight: .bold, design: .default))
                .accentColor(.highlight)
        }
    }
}

struct LiftView: View {
    let lift: Lift?
    
    @State var reps: Int
    @State var sets: Int
    @State var weight: Int
    var presented: Binding<Bool>
    
    init(lift: Lift?, presented: Binding<Bool>) {
        self.lift = lift
        self.presented = presented
        _sets = .init(initialValue: Int(lift?.sets ?? 5))
        _reps = .init(initialValue: Int(lift?.reps ?? 5))
        _weight = .init(initialValue: Int(lift?.weight ?? 45))
    }
    
    var volume: Int {
        Int(reps * sets * weight)
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
                    initialValue: Int(lift?.sets ?? 5)
                )
                LiftPicker(
                    label: "reps",
                    range: 1...20,
                    interval: 1,
                    value: $reps,
                    initialValue: Int(lift?.reps ?? 5)
                )
                LiftPicker(
                    label: "lbs",
                    range: 5...300,
                    interval: 5,
                    value: $weight,
                    initialValue: Int(lift?.weight ?? 45)
                )
                HStack(alignment: .lastTextBaseline, spacing: 15.0) {
                    Text("= \(volume) lbs")
                        .sfCompactDisplay(.medium, size: 54.0)
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                    DifferenceView(initialValue: lift?.volume, value: volume)
                        .offset(x: 0.0, y: -DifferenceView.padding.bottom)
                }.frame(width: .infinity, height: 70.0, alignment: .center)
                Spacer()
            }.padding(
                EdgeInsets(
                    top: 0.0,
                    leading: 30.0,
                    bottom: 0.0,
                    trailing: 30.0
                )
            ).navigationBarItems(trailing: LiftViewCloseButton(presented: presented))
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
            LiftView(lift: lift, presented: $presented)
            LiftView(lift: lift, presented: $presented)
        }
    }
}