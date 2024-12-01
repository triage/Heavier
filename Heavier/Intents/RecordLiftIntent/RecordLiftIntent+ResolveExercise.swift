//
//  RecordLiftIntent+ResolveExercise.swift
//  Heavier
//
//  Created by Eric Schulte on 11/28/24.
//

import Foundation
import AppIntents
import CoreData
import FirebaseFunctions

@available(iOS 18.0, *)
extension RecordLiftIntent {
    /*
     fuzzyMatchName - resolve the provided name using our vocabulary
     use false if the name has already been resolved, as it does in lift_resolve_params
     
     */
    static func resolveExercise(name _name: String, fuzzyMatchName: Bool, context: NSManagedObjectContext, resolve: IntentParameter<AttributedString>) async throws -> Exercise? {
        var name = _name
        if fuzzyMatchName {
            do {
                let response = try await HeavierApp.functions.httpsCallable("exercise_resolve_name").call(["query": _name])
                name = response.data as? String ?? _name
            } catch {}
        }
        
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
                Task {
                    do {
                        try await HeavierApp.functions.httpsCallable("exercise_add_name").call(["query": exercise.name!])
                    } catch {
                        /* noop */
                    }
                }
                return exercise
            } else {
                throw RecordLiftIntentError.willNotCreate
            }
        } else {
            return nil
        }
    }
}
