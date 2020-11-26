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
}
