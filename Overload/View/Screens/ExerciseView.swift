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
    
    func volume(lifts: [Lift]) -> String {
        "= \(Lift.volumeFormatter.string(from: lifts.volume as NSNumber)!) lbs"
    }
    
    var body: some View {
        ForEach(Array(lifts.exercisesGroupedByDay.keys.reversed()), id: \.self) { key in
            let day = key
            let lifts = self.lifts.exercisesGroupedByDay[key]!
            
            VStack(alignment: .leading) {
                
                Text(MostRecentLift.lastLiftDateFormatter.string(from: day))
                    .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                
                ForEach(lifts, id: \.self) { lift in
                    Text(lift.shortDescription)
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.mediumPlus)
                }
                
                Text(volume(lifts: lifts))
                    .sfCompactDisplay(.medium, size: Theme.Font.Size.mediumPlus)
                    .padding([.top, .bottom], Theme.Spacing.medium)
            }   
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
                .padding([.top], -Theme.Spacing.medium)
        }
    }
}

struct RecentLift: View {
    let lift: Lift?
    var body: some View {
        if let lift = lift {
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
                HStack(spacing: Theme.Spacing.giga) {
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
                                .sfCompactDisplay(.medium, size: Theme.Font.Size.giga)
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
    @Environment(\.presentationMode) var presentation
    
    init?(exercise: Exercise?) {
        guard let exercise = exercise else {
            return  nil
        }
        self.exercise = exercise
        lifts = LiftsObservable(exercise: exercise)
    }
    
    var olderLifts: [Lift]? {
        return Array(lifts.lifts.dropLast())
    }
    
    var body: some View {
        List {
            RecentLift(lift: lifts.lifts.last)
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
            LiftView(exercise: exercise, lift: lifts.lifts.last, presented: $liftViewPresented)
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
