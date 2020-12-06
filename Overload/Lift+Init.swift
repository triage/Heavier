//
//  Lift+Init.swift
//  Overload
//
//  Created by Eric Schulte on 12/6/20.
//

import Foundation
import CoreData
import Combine

enum CoreDataError: Error {
    case notFound
    case saveFailed
}

enum LiftSaveState {
    case joined
    case created
}

extension Lift {
    static func == (lhs: Lift, rhs: Lift) -> Bool {
        return lhs.reps == rhs.reps && lhs.weight == rhs.weight
    }
}

extension Lift {
    static func createOrJoin(
        exercise: Exercise,
        sets: Int,
        reps: Int,
        weight: Float) -> Future<LiftSaveState, CoreDataError> {
        
        let exerciseId = exercise.objectID
        return Future { promise in
            let components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
            PersistenceController.shared.container.performBackgroundTask { context in
                guard
                    let exercise = context.object(with: exerciseId) as? Exercise,
                    let lifts = exercise.lifts,
                    let dayPredicate = Lift.Predicate.daySelected(components)
                else {
                    DispatchQueue.main.async {
                        promise(.failure(.notFound))
                    }
                    return
                }
                // find last lift on this date
                
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    Lift.Predicate.exercise(exercise),
                    dayPredicate
                ])
                
                let lift = Lift(context: context)
                lift.reps = Int16(reps)
                lift.sets = Int16(sets)
                lift.weight = Float(Lift.normalize(weight: weight))
                lift.id = UUID()
                lift.timestamp = Date()
                
                func save(state: LiftSaveState) {
                    do {
                        try context.save()
                        DispatchQueue.main.async {
                            promise(.success(state))
                        }
                    } catch let nserror as NSError {
                        print("error:\(nserror)")
                        DispatchQueue.main.async {
                            promise(.failure(.saveFailed))
                        }
                    }
                }
                
                if let lastLiftOnDay = lifts.filtered(using: predicate).sorted(by: { (first, second) -> Bool in
                    guard let first = (first as? Lift)?.timestamp, let second = (second as? Lift)?.timestamp else {
                        return false
                    }
                    return first < second
                }).last as? Lift, lastLiftOnDay == lift, lift.sets == 1 {
                    context.delete(lift)
                    lastLiftOnDay.sets += 1
                    save(state: .joined)
                } else {
                    // no previous lift
                    lift.exercise = exercise
                    save(state: .created)
                }
            }
        }
    }
}

/*
 
 let lift = Lift(context: PersistenceController.shared.container.viewContext)
 lift.reps = Int16(reps)
 lift.sets = Int16(sets)
 lift.weight = Float(Lift.normalize(weight: weight))
 lift.id = UUID()
 lift.timestamp = Date()
 lift.exercise = exercise
 do {
     try? PersistenceController.shared.container.viewContext.save()
 }
 */
