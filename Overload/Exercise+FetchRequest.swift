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
    static func searchFetchRequest(query: String?) -> FetchRequest<Exercise> {
        let predicate: NSPredicate?
        if let query = query, query.count > 0 {
            predicate = NSPredicate(format: "name CONTAINS %@", query as CVarArg)
        } else {
            predicate = nil
        }
        return FetchRequest<Exercise>(
            entity: Exercise.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Exercise.name, ascending: true)
            ],
            predicate: predicate, animation: .default
        )
    }
}
