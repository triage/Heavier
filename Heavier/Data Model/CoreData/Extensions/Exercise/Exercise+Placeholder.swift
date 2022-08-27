//
//  Exercise+Placeholder.swift
//  Heavier
//
//  Created by Eric on 8/27/22.
//

import Foundation
import CoreData

extension Exercise {
    
    static func createPlaceholder(context: NSManagedObjectContext) -> Exercise? {
        guard let exercise = Exercise(name: "", relevance: 0, context: context) else {
            return nil
        }
        exercise.placeholder = true
        return exercise
    }
    
    static func fetchPlaceholder(context: NSManagedObjectContext) throws -> Exercise? {
        let request: NSFetchRequest<Exercise> = NSFetchRequest()
        request.entity = Exercise.entity()
        request.predicate = NSPredicate(format: "placeholder == YES")
        let result = try context.fetch(request)
        return result.first
    }
    
    static func createPlaceholderIfNecessary(context: NSManagedObjectContext) -> Exercise? {
        if let placeholder = try? fetchPlaceholder(context: context) {
            return placeholder
        } else if let placeholder = createPlaceholder(context: context) {
            try? context.save()
            return placeholder
        }
        return nil
    }
}
