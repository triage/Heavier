//
//  ExerciseView.swift
//  Overload
//
//  Created by Eric Schulte on 9/27/20.
//

import Foundation
import SwiftUI
import CoreData

struct OlderLifts: View {
    private let sections: [NSFetchedResultsSectionInfo]
    
    init?(sections: [NSFetchedResultsSectionInfo]?) {
        guard let sections = sections else {
            return  nil
        }
        self.sections = sections
    }
    
    func volume(lifts: [Lift]) -> String? {
        guard
            let volume = Lift.localize(weight: lifts.volume),
            let formatted = Lift.weightsFormatter.string(from: NSNumber(value: volume)) else {
                return nil
        }
        return "= \(formatted) \(Settings.shared.units.label)"
    }
    
    struct GroupedLiftsOnDay: View {
        let lifts: [Lift]
        var body: some View {
            ForEach(Array(lifts.groupedByWeightAndReps.values).sorted(by: { (first, second) -> Bool in
                first.mostRecent.timestamp! < second.mostRecent.timestamp!
            }), id: \.self) { lifts in
                if let shortDescription = lifts.shortDescription(units: Settings.shared.units) {
                    Text(shortDescription)
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.mediumPlus)
                }
            }
        }
    }
    
    var body: some View {
        ForEach(sections, id: \.name) { section in
            let lifts = section.objects as! [Lift]
            let day = lifts.first!.timestamp!
            
            VStack(alignment: .leading) {
                
                Text(MostRecentLift.lastLiftDateFormatter.string(from: day))
                    .sfCompactDisplay(.bold, size: Theme.Font.Size.mediumPlus)
                    .padding([.bottom, .top], Theme.Spacing.small)
                
                GroupedLiftsOnDay(lifts: lifts)
                
                if let volume = volume(lifts: lifts) {
                    Text(volume)
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.mediumPlus)
                        .padding([.top, .bottom], Theme.Spacing.medium)
                }
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
    
    var volume: String? {
        guard let lift = lift, let localized = Lift.localize(weight: lift.volume) else {
            return nil
        }
        let number = NSNumber(value: localized)
        return Lift.weightsFormatter.string(from: number)
    }
    
    var body: some View {
        if let lift = lift, let volume = volume {
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
                        RecentLiftMetric(
                            value: Lift.weightsFormatter.string(from: NSNumber(value: lift.weightLocalized.weight))!,
                            label: Settings.shared.units.label
                        )
                    }
                    Spacer()
                }
                if !lift.isBodyweight {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(volume)
                                .sfCompactDisplay(.medium, size: Theme.Font.Size.giga)
                                .minimumScaleFactor(1.0)
                                .lineLimit(1)
                            Text("total volume (\(Settings.shared.units.label)")
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
            return nil
        }
        self.exercise = exercise
        lifts = LiftsObservable(exercise: exercise, ascending: false)
    }
    
    struct Content: View {
        @ObservedObject var lifts: LiftsObservable
        var body: some View {
            if lifts.lifts.count > 0 {
                VStack {
                    List {
                        RecentLift(lift: lifts.lifts.first)
                        OlderLifts(sections: lifts.sections)
                    }
                    .listStyle(PlainListStyle())
                }
            } else {
                Text("No lifts recorded yet.")
                    .sfCompactDisplay(.medium, size: Theme.Font.Size.mediumPlus)
            }
        }
    }
    
    var body: some View {
        Content(lifts: lifts)
        .navigationTitle(exercise.name!)
        .navigationBarItems(trailing: Button(action: {
            liftViewPresented = true
        }, label: {
            Image(systemName: "plus")
                .font(.system(size: Theme.Font.Size.large))
        })).sheet(isPresented: $liftViewPresented) {
            LiftView(exercise: exercise, lift: lifts.lifts.first, presented: $liftViewPresented)
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
        
        let exerciseNoLifts = Exercise(context: PersistenceController.shared.container.viewContext)
        exerciseNoLifts.name = "Romanian Deadlift"
        exerciseNoLifts.id = UUID()
        return Group {
            NavigationView {
                ExerciseView(
                    exercise: exercise
                )
                ExerciseView(
                    exercise: exerciseNoLifts
                )
            }
        }
    }
}
