//
//  Lift+MostRecent.swift
//  Heavier
//
//  Created by Eric Schulte on 12/2/24.
//

import Foundation
import CoreData

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
    static func liftsOnPreviousDay(exercise: Exercise) -> [Lift]? {
        
    }
}
