//
//  Lift+MostRecent.swift
//  Heavier
//
//  Created by Eric Schulte on 12/2/24.
//

import Foundation
import CoreData
import Algorithms

extension Lift.CoreData {
    /*
     In the case where a user has omitted the exercise name, we can
     try to fill it in from guessing that, if they did a lift less
     than 5 minutes ago, they're probably doing the same lift
     */
    static func mostRecent(context: NSManagedObjectContext) -> Lift? {
        let maximumTimeAgo = Date().addingTimeInterval(-5 * 60)
        let fetchRequest: NSFetchRequest<Lift> = Lift.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp >= %@", maximumTimeAgo as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 1
        return try? context.fetch(fetchRequest).first
    }
}

extension Lift {
    func wasFirstLiftOfExerciseToday() throws -> Bool {
        guard let managedObjectContext = managedObjectContext else {
            return false
        }
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        guard let fetchRequest = Lift.CoreData.fetchRequest(day: dateComponents) else {
            return false
        }
        let liftsToday = try? managedObjectContext.fetch(fetchRequest)
        if liftsToday?.count == 1, let first = liftsToday?.first {
            return first == self
        }
        return false
    }
}

extension Exercise {
    func liftsOnPreviousDay() -> (Date, [Lift])? {
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }
        let fetchRequest = Lift.CoreData.fetchRequest(exercise: self, ascending: false)
        let dates = try? managedObjectContext.fetch(fetchRequest).compactMap({ lift in
            return lift.timestamp
        }).map {
            Calendar.current.startOfDay(for: $0)
        }.filter {
            Calendar.current.startOfDay(for: $0) != Calendar.current.startOfDay(for: Date())
        }.uniqued().sorted(by: { first, second in
            return first > second
        })
        if let previousDate = dates?.first {
            let fetchRequest = Lift.CoreData.fetchRequest(exercise: self, ascending: false, date: previousDate)
            if let lifts = try? managedObjectContext.fetch(fetchRequest), !lifts.isEmpty {
                return (previousDate, lifts)
            }
        }
        return nil
    }
    
    func liftsToday() -> [Lift]? {
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }
        let fetchRequest = Lift.CoreData.fetchRequest(exercise: self, ascending: true, date: Date())
        let lifts = try? managedObjectContext.fetch(fetchRequest)
        print("liftsToday: \(lifts ?? [])")
        return lifts
    }
}
