//
//  Lift+FetchRequest.swift
//  Overload
//
//  Created by Eric Schulte on 11/21/20.
//

import Foundation
import CoreData
import SwiftUI

extension Lift {
    
    enum SortDescriptor {
        static func timestamp(ascending: Bool) -> NSSortDescriptor {
            NSSortDescriptor(key: "timestamp", ascending: ascending)
        }
    }
    
    enum Predicate {
        static func daySelected(_ daySelected: DateComponents) -> NSPredicate? {
            guard let range = daySelected.dayRange else {
                return nil
            }
            return NSPredicate(format: "(timestamp >= %@) AND (timestamp <= %@)",
                        range.lowerBound as CVarArg,
                        range.upperBound as CVarArg
            )
        }
        static func exercise(_ exercise: Exercise) -> NSPredicate {
            NSPredicate(format: "exercise = %@", exercise as CVarArg)
        }
    }
    
    static func fetchRequest(exercise: Exercise?) -> NSFetchRequest<Lift> {
        let fetchRequest: NSFetchRequest<Lift> = Lift.fetchRequest()
        if let exercise = exercise {
            fetchRequest.predicate = Lift.Predicate.exercise(exercise)
        }
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Lift.timestamp, ascending: true)
        ]
        return fetchRequest
    }
    
    static func fetchRequest(day dayComponents: DateComponents) -> NSFetchRequest<Lift>? {
        var day = dayComponents
        day.calendar = Calendar.current
        guard
            let date = day.date,
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
                return nil
        }
        let range = Calendar.current.startOfDay(for: date)...endOfDay
        let fetchRequest: NSFetchRequest<Lift> = Lift.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "(timestamp >= %@) AND (timestamp <= %@)",
            range.lowerBound as CVarArg, range.upperBound as CVarArg
        )
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Lift.timestamp, ascending: true)
        ]
        return fetchRequest
    }

    static func searchFetchRequest(query: String?) -> FetchRequest<Lift> {
        let predicate: NSPredicate?
        if let query = query, query.count > 0 {
            predicate = NSPredicate(format: "exercise.name CONTAINS[c] %@", query as CVarArg)
        } else {
            predicate = nil
        }
        return FetchRequest<Lift>(
            entity: Lift.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Lift.timestamp, ascending: true)
            ],
            predicate: predicate, animation: .default
        )
    }
}
