//
//  Exercise+FetchRequest.swift
//  Overload
//
//  Created by Eric Schulte on 10/14/20.
//

import Foundation
import SwiftUI

extension Exercise {
    static func fetchRequest(query: String) -> FetchRequest<Exercise> {
        return FetchRequest(
            entity: Exercise.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Exercise.name, ascending: true)
            ],
            predicate: NSPredicate(format: "name CONTAINS %@", query), animation: .default
        )
    }
}
