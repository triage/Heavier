//
//  SearchLiftIntent.swift
//  Heavier
//
//  Created by Eric Schulte on 11/24/24.
//

import Foundation
import AppIntents
import CoreData
import CoreLocation

@available(iOS 18.0, *)
@AssistantIntent(schema: .journal.search)
struct ExerciseSearchIntent: ShowInAppSearchResultsIntent {
    
    static var searchScopes: [StringSearchScope] = [.general]

    @Parameter(title: "Exercise name")
    var criteria: StringSearchCriteria
    
    static func resolveExercise(name: String, context: NSManagedObjectContext, resolve: IntentParameter<StringSearchCriteria>) async throws -> Exercise? {
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
                StringSearchCriteria(term: $0.name!)
            }, dialog: IntentDialog("We found a few results for \(name). Which one do you want?"))
            if let found = try? Exercise.CoreData.findExactMatch(name: String(disambiguated.term), caseSensitive: true, context: context) {
                return found
            }
        }
        return nil
    }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
