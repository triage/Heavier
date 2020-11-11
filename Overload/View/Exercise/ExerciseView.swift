//
//  ExerciseView.swift
//  Overload
//
//  Created by Eric Schulte on 9/27/20.
//

import Foundation
import SwiftUI

struct OlderLifts: View {
    let lifts: ArraySlice<Lift>?
    var body: some View {
        if let lifts = lifts {
            ForEach(lifts) { lift in
                VStack {
                    HStack(alignment: .firstTextBaseline, spacing: 5.0) {
                        Text("\(lift.sets)")
                            .sfCompactDisplay(.medium, size: 24.0)
                        Text("sets")
                            .sfCompactDisplay(.medium, size: 14.0)
                            .foregroundColor(.label)
                        Text("\(lift.reps)")
                            .sfCompactDisplay(.medium, size: 24.0)
                        Text("reps")
                            .sfCompactDisplay(.medium, size: 14.0)
                            .foregroundColor(.label)
                        Text("\(Lift.weightsFormatter.string(from: lift.weight as NSNumber)!) lbs")
                            .sfCompactDisplay(.medium, size: 24.0)
                        Spacer()
                        Text("=")
                            .sfCompactDisplay(.medium, size: 14.0)
                            .foregroundColor(.label)
                        Text("\(Lift.weightsFormatter.string(from: lift.volume as NSNumber)!) lbs")
                            .sfCompactDisplay(.medium, size: 24.0)
                    }
                    HStack {
                        Text(MostRecentLift.lastLiftDateFormatter.string(from: lift.timestamp!))
                            .sfCompactDisplay(.medium, size: 16.0)
                        Spacer()
                    }
                }.padding(EdgeInsets(top: 10.0, leading: 0.0, bottom: 10.0, trailing: 0.0))
            }
        } else {
            EmptyView()
        }
    }
}

struct RecentLift: View {
    let lift: Lift?
    var body: some View {
        if let lift = lift {
            HStack(alignment: .firstTextBaseline, spacing: 10.0) {
                Text("\(lift.sets)")
                    .sfCompactDisplay(.medium, size: 44.0)
                Text("sets")
                    .sfCompactDisplay(.medium, size: 14.0)
                    .foregroundColor(.label)
                Text("\(lift.reps)")
                    .sfCompactDisplay(.medium, size: 44.0)
                Text("reps")
                    .sfCompactDisplay(.medium, size: 14.0)
                    .foregroundColor(.label)
                Text("\(Lift.weightsFormatter.string(from: lift.weight as NSNumber)!) lbs")
                    .sfCompactDisplay(.medium, size: 44.0)
                Spacer()
                Text("=")
                    .sfCompactDisplay(.medium, size: 14.0)
                    .foregroundColor(.label)
                Text("\(Lift.weightsFormatter.string(from: lift.volume as NSNumber)!) lbs")
                    .sfCompactDisplay(.medium, size: 24.0)
            }
        } else {
            EmptyView()
        }
    }
}

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
    
    var olderLifts: ArraySlice<Lift>? {
        if let lifts = exercise?.lifts?.array as? [Lift] {
            return lifts.dropFirst()
        }
        return nil
    }
    
    var body: some View {
        List {
            RecentLift(lift: exercise?.lifts?.firstObject as? Lift)
            OlderLifts(lifts: olderLifts)
        }
        .listStyle(PlainListStyle())
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
        
        var lifts = [Lift]()
        for i in 0...20 {
            let lift = Lift(context: PersistenceController.shared.container.viewContext)
            lift.reps = 10
            lift.sets = Int16(i + 1)
            lift.weight = 135
            lift.id = UUID()
            lift.timestamp = Date()
            lifts.append(lift)
        }
        
        exercise.lifts = NSOrderedSet(array: lifts)
        
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
