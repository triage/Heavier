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
        fetchRequest.predicate = NSPredicate(format: "date >= %@", maximumTimeAgo as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = 1
        do {
            let result = try context.fetch(fetchRequest)
            return (result.first)
        } catch {
            return nil
        }
    }
}

extension Lift {
    static func wasFirstLiftOfExerciseToday(lift: Lift, context: NSManagedObjectContext) throws -> Bool {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        guard let fetchRequest = Lift.CoreData.fetchRequest(day: dateComponents) else {
            return false
        }
        let liftsToday = try? context.fetch(fetchRequest)
        if liftsToday?.count == 1, let first = liftsToday?.first {
            return first == lift
        }
        return false
    }
}

extension Exercise {
    func liftsOnPreviousDay(context: NSManagedObjectContext) -> (Date, [Lift])? {
        let fetchRequest = Lift.CoreData.fetchRequest(exercise: self, ascending: false)
        let dates = try? context.fetch(fetchRequest).compactMap({ lift in
            return lift.timestamp
        }).map {
            Calendar.current.startOfDay(for: $0)
        }.filter {
            Calendar.current.startOfDay(for: $0) != Calendar.current.startOfDay(for: Date())
        }.uniqued().sorted(by: { first, second in
            return first > second
        })
        if let previousDate = dates?.first {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: previousDate)
            let fetchRequest = Lift.CoreData.fetchRequest(exercise: self, ascending: false, day: components)
            if let lifts = try? context.fetch(fetchRequest), !lifts.isEmpty {
                return (previousDate, lifts)
            }
        }
        return nil
    }
    
    func liftsToday(context: NSManagedObjectContext) -> [Lift]? {
        let fetchRequest = Lift.CoreData.fetchRequest(exercise: self, ascending: false)
        return try? context.fetch(fetchRequest).compactMap {
            if let timestamp = $0.timestamp, Calendar.current.startOfDay(for: timestamp) == Calendar.current.startOfDay(for: Date()) {
                return $0
            }
            return nil
        }
    }
}
