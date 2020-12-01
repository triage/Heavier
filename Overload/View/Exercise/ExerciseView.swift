//
//  ExerciseView.swift
//  Overload
//
//  Created by Eric Schulte on 9/27/20.
//

import Foundation
import SwiftUI

struct OlderLifts: View {
    private let lifts: [Lift]
    
    init?(lifts: [Lift]?) {
        guard let lifts = lifts else {
            return  nil
        }
        self.lifts = lifts
    }
    
    var body: some View {
        ForEach(lifts) { lift in
            VStack {
                HStack(alignment: .firstTextBaseline, spacing: 5.0) {
                    Text("\(lift.sets)")
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                    Text("x")
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.medium)
                        .foregroundColor(.label)
                    Text("\(lift.reps)")
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                    if !lift.isBodyweight {
                        Text("x")
                            .sfCompactDisplay(.medium, size: Theme.Font.Size.medium)
                            .foregroundColor(.label)
                        Text("\(Lift.weightsFormatter.string(from: lift.weight as NSNumber)!)")
                            .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                        Text("lbs")
                            .sfCompactDisplay(.medium, size: Theme.Font.Size.medium)
                            .foregroundColor(.label)
                    }
                    Spacer()
                    if !lift.isBodyweight {
                        Text("=")
                            .sfCompactDisplay(.medium, size: Theme.Font.Size.medium)
                            .foregroundColor(.label)
                        Text("\(Lift.volumeFormatter.string(from: lift.volume as NSNumber)!) lbs")
                            .lineLimit(0)
                            .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                    }
                }
                HStack {
                    Text(MostRecentLift.lastLiftDateFormatter.string(from: lift.timestamp!))
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                    Spacer()
                }
            }.padding([.top, .bottom], 10.0)
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
                .sfCompactDisplay(.medium, size: Theme.Font.Size.medium)
                .lineLimit(0)
                .padding([.top], -14.0)
        }
    }
}

struct RecentLift: View {
    let lifts: [Lift]?
    var body: some View {
        if let lift = lifts?.first {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("most recent lift:")
                            .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                        Text(MostRecentLift.lastLiftDateFormatter.string(from: lift.timestamp!))
                            .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                    }
                    Spacer()
                }
                HStack(spacing: 25.0) {
                    RecentLiftMetric(value: lift.sets, label: "sets")
                    RecentLiftMetric(value: lift.reps, label: "reps")
                    if !lift.isBodyweight {
                        RecentLiftMetric(value: lift.weight, label: "lbs")
                    }
                    Spacer()
                }
                if !lift.isBodyweight {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(Lift.volumeFormatter.string(from: lift.volume as NSNumber)!)")
                                .sfCompactDisplay(.medium, size: 54.0)
                                .minimumScaleFactor(1.0)
                                .lineLimit(1)
                            Text("total volume (lbs)")
                                .sfCompactDisplay(.medium, size: Theme.Font.Size.medium)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], Theme.Spacing.large)
        } else {
            EmptyView()
        }
    }
}

struct ExerciseView: View {
    let exercise: Exercise
    @State var liftViewPresented = false
    @ObservedObject var lifts: LiftsObservable
    init?(exercise: Exercise?) {
        guard let exercise = exercise else {
            return  nil
        }
        self.exercise = exercise
        lifts = LiftsObservable(exercise: exercise)
    }
    var olderLifts: [Lift]? {
        return Array(lifts.lifts.dropFirst())
    }
    var body: some View {
        List {
            RecentLift(lifts: lifts.sections.first?.objects as? [Lift])
            OlderLifts(lifts: olderLifts)
        }
        .listStyle(PlainListStyle())
        .navigationTitle(exercise.name!)
        .navigationBarItems(trailing: Button(action: {
            liftViewPresented = true
        }, label: {
            Image(systemName: "plus")
                .font(.system(size: Theme.Font.Size.large))
        })).sheet(isPresented: $liftViewPresented) {
            LiftView(exercise: exercise, lift: exercise.lifts?.lastObject as? Lift, presented: $liftViewPresented)
        }
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        let exercise = Exercise(context: PersistenceController.shared.container.viewContext)
        exercise.name = "Romanian Deadlift"
        exercise.id = UUID()
        var lifts = [Lift]()
        for iterator in 0...20 {
            let lift = Lift(context: PersistenceController.shared.container.viewContext)
            lift.reps = 10
            lift.sets = Int16(iterator + 10)
            lift.weight = 100
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
        }
    }
}
