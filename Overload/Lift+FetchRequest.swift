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
    static func fetchRequest(exercise: Exercise) -> NSFetchRequest<Lift> {
        let predicate = NSPredicate(format: "exercise = %@", exercise as CVarArg)
        let fetchRequest: NSFetchRequest<Lift> = Lift.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Lift.timestamp, ascending: false)
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
