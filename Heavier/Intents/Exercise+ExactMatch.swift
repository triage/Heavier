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
    static func findExactMatch(name: String, caseSensitive: Bool, context: NSManagedObjectContext) throws -> Exercise? {
        do {
            guard let query = Exercise.CoreData.exactMatch(name, caseSensitive: caseSensitive),
                  let exactMatches = try? context.fetch(query) else {
                throw AppIntentError.Unrecoverable.entityNotFound
            }
            // look for exact match
            if let found = exactMatches.first, exactMatches.count == 1 {
                return found
            }
            return nil
        } catch (let error) {
            throw error
        }
    }
}
