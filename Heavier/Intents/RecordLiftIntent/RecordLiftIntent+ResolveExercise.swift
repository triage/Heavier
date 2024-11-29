//
//  RecordLiftIntent+ResolveExercise.swift
//  Heavier
//
//  Created by Eric Schulte on 11/28/24.
//

import Foundation
import AppIntents
import CoreData

@available(iOS 18.0, *)
extension RecordLiftIntent {
    
    static func resolveExercise(name: String, context: NSManagedObjectContext, resolve: IntentParameter<AttributedString>) async throws -> Exercise? {
        let exactMatch = try? Exercise.CoreData.findExactMatch(name: name, caseSensitive: false, context: context)
        // look for exact match
        if let found = exactMatch {
            return found
        }
        // no exact match found, or multiple exact matches found. Search for
        // exercises _like_ search and ask the user to disambiguate
        guard let matches = try? context.fetch(Exercise.CoreData.searchFetchRequest(name)) else {
            throw AppIntentError.Unrecoverable.entityNotFound
        }
        
        if matches.count > 0 {
            // Multiple matches. Disambiguate.
            let disambiguated = try await resolve.requestDisambiguation(among: matches.map {
                AttributedString($0.name!)
            }, dialog: IntentDialog("We found a few results for \(name). Which one do you want to use?"))
            print("disambiguated: \(disambiguated)")
            if let found = try? Exercise.CoreData.findExactMatch(name: String(disambiguated.characters), caseSensitive: true, context: context) {
                return found
            }
        }
        if matches.count == 0 {
            let shouldCreate = try await resolve.requestConfirmation(for: AttributedString(name), dialog: IntentDialog(stringLiteral: String(localized: "Create a new exercise for \(name)?")))
            if shouldCreate {
                let exercise = Exercise(context: context)
                exercise.name = String(name).capitalized
                exercise.id = UUID()
                return exercise
            } else {
                throw RecordLiftIntentError.willNotCreate
            }
        } else {
            return nil
        }
    }
}
