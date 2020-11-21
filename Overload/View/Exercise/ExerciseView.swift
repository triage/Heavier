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
                        Text("x")
                            .sfCompactDisplay(.medium, size: 14.0)
                            .foregroundColor(.label)
                        Text("\(lift.reps)")
                            .sfCompactDisplay(.medium, size: 24.0)
                        Text("x")
                            .sfCompactDisplay(.medium, size: 14.0)
                            .foregroundColor(.label)
                        Text("\(Lift.weightsFormatter.string(from: lift.weight as NSNumber)!)")
                            .sfCompactDisplay(.medium, size: 24.0)
                        Text("lbs")
                            .sfCompactDisplay(.medium, size: 14.0)
                            .foregroundColor(.label)
                        Spacer()
                        Text("=")
                            .sfCompactDisplay(.medium, size: 14.0)
                            .foregroundColor(.label)
                        Text("\(Lift.volumeFormatter.string(from: lift.volume as NSNumber)!) lbs")
                            .lineLimit(0)
                            .sfCompactDisplay(.medium, size: 24.0)
                    }
                }.padding(EdgeInsets(top: 10.0, leading: 0.0, bottom: 10.0, trailing: 0.0))
            }
        } else {
            EmptyView()
        }
    }
}

struct RecentLiftMetric: View {
    let value: CustomStringConvertible
    let label: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(value.description)
                .sfCompactDisplay(.medium, size: 44.0)
                .minimumScaleFactor(0.2)
                .lineLimit(0)
            Text(label)
                .sfCompactDisplay(.medium, size: 14.0)
                .lineLimit(0)
                .padding(EdgeInsets(top: -14.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
        }
    }
}

struct RecentLift: View {
    let lift: Lift?
    var body: some View {
        if let lift = lift {
            VStack(alignment: .leading) {
                HStack(spacing: 25.0) {
                    RecentLiftMetric(value: lift.sets, label: "sets")
                    RecentLiftMetric(value: lift.reps, label: "reps")
                    RecentLiftMetric(value: lift.weight, label: "lbs")
                    Spacer()
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(Lift.volumeFormatter.string(from: lift.volume as NSNumber)!)")
                            .sfCompactDisplay(.medium, size: 54.0)
                            .minimumScaleFactor(1.0)
                            .lineLimit(1)
                        Text("total volume (lbs)")
                            .sfCompactDisplay(.medium, size: 14.0)
                    }
                }
                Text(MostRecentLift.lastLiftDateFormatter.string(from: lift.timestamp!))
                    .padding(EdgeInsets(top: 10.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 20.0, leading: 0.0, bottom: 20.0, trailing: 0.0))
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
            lift.sets = Int16(i + 10)
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
