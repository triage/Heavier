//
//  ExerciseOnDate.swift
//  Heavier
//
//  Created by Eric Schulte on 7/4/21.
//

import Foundation
import SwiftUI
import CoreData

final class SheetManager: NSObject, ObservableObject {
    @Published var lift: Lift?
}

struct ExerciseOnDate: View {
    let exercise: Exercise
    let date: Date
    
    @StateObject private var lifts: LiftsObservable
    @State var presented = false
    @StateObject var sheetManager = SheetManager()
    
    init(exercise: Exercise, date: Date, context managedObjectContext: NSManagedObjectContext) {
        self.exercise = exercise
        self.date = date
        
        var dateComponents = Calendar.autoupdatingCurrent.dateComponents(
            [.day, .month, .year],
            from: date
        )
        dateComponents.calendar = Calendar.autoupdatingCurrent
        
        _lifts = .init(
            wrappedValue: LiftsObservable(
                exercise: exercise,
                dateComponents: dateComponents,
                context: managedObjectContext
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
    
    struct Notes: View {
        let notes: String?
        var body: some View {
            if let notes = notes {
                VStack {
                    Text(notes)
                        .padding(
                            EdgeInsets(
                                top: 0.0,
                                leading: 0.0,
                                bottom: Theme.Spacing.medium,
                                trailing: 0.0
                            )
                        )
                }
            } else {
                EmptyView()
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(lifts.lifts, id: \.id) { lift in
                Group {
                    Button(action: {
                        sheetManager.lift = lift
                        self.presented = true
                    }, label: {
                        VStack(alignment: .leading, spacing: -Theme.Spacing.medium) {
                            HStack {
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
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: Theme.Font.Size.large))
                                    .opacity(0.25)
                                    .scaleEffect(0.5)
                            }
                            Notes(notes: lift.notes)
                        }
                    })
                }
            }
        }.navigationTitle(title)
        .listStyle(PlainListStyle())
        .sheet(isPresented: $presented, content: {
            LiftView(exercise: exercise, lift: sheetManager.lift, presented: $presented, mode: .editing)
        })
    }
    
    struct ExerciseOnDate_Previews: PreviewProvider {
        
        static var previews: some View {
            Settings.shared.units = .metric
            
            let exercise = Exercise(context: PersistenceController.preview.container.viewContext)
            exercise.name = "Romanian Deadlift"
            exercise.id = UUID()
            var lifts = [Lift]()
            for index in 1...20 {
                let lift = Lift(context: PersistenceController.preview.container.viewContext)
                lift.reps = Int16(index)
                lift.sets = 4
                if index % 2 == 0 {
                    lift.notes = "Light weight, baby!"
                }
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
                        date: Date(),
                        context: PersistenceController.preview.container.viewContext
                    )
                }
            }.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
