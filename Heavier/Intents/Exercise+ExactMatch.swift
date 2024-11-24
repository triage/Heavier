//
//  Exercise+ExactMatch.swift
//  Heavier
//
//  Created by Eric Schulte on 11/24/24.
//

import Foundation
import CoreData
import AppIntents

@available(iOS 18.0, *)
extension Exercise.CoreData {
    static func findExactMatch(name: String, context: NSManagedObjectContext) throws -> [Exercise]? {
        guard let exactMatches = try? context.fetch(Exercise.CoreData.findExactMatch(name)) else {
            throw AppIntentError.Unrecoverable.entityNotFound
        }
        // look for exact match
        if let found = exactMatches.first, exactMatches.count == 1 {
            return [found]
        }
        return nil
    }
}
