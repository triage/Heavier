//
//  Exercise+LiftDate.swift
//  Overload
//
//  Created by Eric Schulte on 11/22/20.
//

import Foundation
import CoreData

extension Exercise {
    var lastLiftDate: Date? {
        return lastLift?.timestamp
    }
    
    private static var groupingDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    static var lastGroupCache = NSCache<Exercise, NSArray>()
    
    func clearLastGroupShortDescriptionCache() {
        Exercise.lastGroupCache.removeObject(forKey: self)
    }
    
    var lastGroup: [Lift]? {
        if let cached = Exercise.lastGroupCache.object(forKey: self) as? [Lift] {
            return cached
        }
        guard let lastLift = lastLift,
              let timestamp = lastLift.timestamp,
              let exercise = lastLift.exercise
        else {
            return nil
        }
        let components = Calendar.current.dateComponents([.day, .month, .year], from: timestamp)
        // get the group it belongs to
        
        guard let dayPredicate = Lift.CoreData.Predicate.daySelected(components) else {
            return nil
        }
        
        let fetchRequest: NSFetchRequest<Lift> = Lift.fetchRequest()
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            dayPredicate,
            Lift.CoreData.Predicate.exercise(exercise),
            Lift.CoreData.Predicate.reps(lastLift.reps),
            Lift.CoreData.Predicate.weight(lastLift.weight)
        ])
        fetchRequest.predicate = predicate
        
        do {
            let results = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
            Exercise.lastGroupCache.setObject(results as NSArray, forKey: self)
            return results
        } catch {
            return nil
        }
    }
    
    var lastLift: Lift? {
        return (lifts?.array as? [Lift])?.sorted {
            
            if $0.timestamp != nil && $1.timestamp == nil {
                return true
            } else if $0.timestamp == nil && $1.timestamp != nil {
                return false
            }
            
            guard let first = $0.timestamp, let second = $1.timestamp else {
                return true
            }
            return first > second
        }.first
    }
}
