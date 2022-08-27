//
//  Exercise+FetchRequest.swift
//  Overload
//
//  Created by Eric Schulte on 10/14/20.
//

import Foundation
import CoreData
import SwiftUI

extension Exercise {
    enum CoreData {
        static func predicate(query: String?) -> NSPredicate? {
            let predicate: NSPredicate?
            if let query = query, query.count > 0 {
                let words = query.split(separator: " ")
                var predicates: [NSPredicate] = words.map {
                    NSPredicate(format: "name CONTAINS[c] %@", $0 as CVarArg)
                }
                predicates.append(
                    NSPredicate(format: "placeholder == NO")
                )
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            } else {
                predicate = nil
            }
            return predicate
        }
        
        static func searchFetchRequest(_ query: String?) -> NSFetchRequest<Exercise> {
            let predicate: NSPredicate?
            if let query = query, query.count > 0 {
                let words = query.split(separator: " ")
                var predicates: [NSPredicate] = words.map {
                    NSPredicate(format: "name CONTAINS[c] %@", $0 as CVarArg)
                }
                predicates.append(
                    NSPredicate(format: "placeholder == NO")
                )
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            } else {
                predicate = nil
            }
            let request = NSFetchRequest<Exercise>(entityName: Exercise.entity().name!)
            request.predicate = predicate
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \Exercise.relevance, ascending: false),
                NSSortDescriptor(keyPath: \Exercise.name, ascending: true)
            ]
            return request
        }
    }
}
