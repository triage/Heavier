//
//  Exercise+FetchRequest.swift
//  Overload
//
//  Created by Eric Schulte on 10/14/20.
//

import Foundation
import CoreData

extension Exercise {
    static var exercisesFetchRequest: NSFetchRequest<Exercise> {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
//        request.predicate = NSPredicate(format: "name CONTAINS %@", "ROMANIAN" as CVarArg)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Exercise.name, ascending: true)
        ]
        return request
    }
    
    static func searchFetchRequest(query: String) -> NSFetchRequest<Exercise> {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS %@", query as CVarArg)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Exercise.name, ascending: true)
        ]
        return request
    }
}
