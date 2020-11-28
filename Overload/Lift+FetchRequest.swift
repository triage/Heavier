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
    static func fetchRequest(exercise: Exercise?) -> NSFetchRequest<Lift> {
        let fetchRequest: NSFetchRequest<Lift> = Lift.fetchRequest()
        if let exercise = exercise {
            fetchRequest.predicate = NSPredicate(format: "exercise = %@", exercise as CVarArg)
        }
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Lift.timestamp, ascending: false)
        ]
        return fetchRequest
    }
    
    static func fetchRequest(day dayComponents: DateComponents?) -> NSFetchRequest<Lift>? {
        guard var day = dayComponents else {
            return nil
        }
        day.calendar = Calendar.current
        guard
            let date = day.date,
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
                return nil
        }
        let range = Calendar.current.startOfDay(for: date)...endOfDay
        let fetchRequest: NSFetchRequest<Lift> = Lift.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "(timestamp >= %@) AND (timestamp <= %@)", range.lowerBound as CVarArg, range.upperBound as CVarArg)
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
