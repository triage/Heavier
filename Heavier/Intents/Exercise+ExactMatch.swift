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
    static func findExactMatch(name: String, context: NSManagedObjectContext) throws -> Exercise? {
        do {
            guard let exactMatches = try? context.fetch(Exercise.CoreData.findExactMatch(name)) else {
                print("couldn't fetch!")
                throw AppIntentError.Unrecoverable.entityNotFound
            }
            // look for exact match
            if let found = exactMatches.first, exactMatches.count == 1 {
                print("found!!!")
                return found
            }
            print("not found - return nil")
            return nil
        } catch (let error) {
            print("error fetching exact match")
            print(error)
            throw error
        }
    }
}
