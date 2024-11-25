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
struct ExerciseSearchIntent {
    
    static var searchScopes: [StringSearchScope] = [.general]

    @Parameter
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
            print("couldn't query for possible matches")
            throw AppIntentError.Unrecoverable.entityNotFound
        }
        
        if matches.count > 0 {
            // Multiple matches. Disambiguate.
            let disambiguated = try await resolve.requestDisambiguation(among: matches.map {
                StringSearchCriteria(term: $0.name!)
            }, dialog: IntentDialog("We found a few results for \(name). Which one do you want?"))
            print("disambiguated: \(disambiguated)")
            if let found = try? Exercise.CoreData.findExactMatch(name: String(disambiguated.term), caseSensitive: true, context: context) {
                print("returning exact match from disambiguity")
                print("found:\(found)")
                return found
            }
        }
        return nil
    }
    
    func perform() async throws -> some ReturnsValue<ExerciseSearchEntity> {
        if let exercise = try await ExerciseSearchIntent.resolveExercise(name: criteria.term, context: PersistenceController.shared.container.viewContext, resolve: $criteria), let entity = ExerciseSearchEntity(exercise: exercise) {
            return .result(value: entity, dialog: IntentDialog(entity.displayRepresentation.title))
        } else {
            throw AppIntentError.Unrecoverable.entityNotFound
        }
    }
    
}

@available(iOS 18.0, *)
struct ExerciseSearchEntity {
    struct Query: EntityStringQuery {
        func entities(for identifiers: [ExerciseSearchEntity.ID]) async throws -> [ExerciseSearchEntity] {
            let request = Exercise.CoreData.matchingIdentifiers(identifiers)
            let context = PersistenceController.shared.container.viewContext
            guard let results = try? context.fetch(request) else {
                return []
            }
            return results.compactMap { ExerciseSearchEntity(exercise: $0) }
        }
        func entities(matching string: String) async throws -> [ExerciseSearchEntity] {
            let request = Exercise.CoreData.searchFetchRequest(string)
            let context = PersistenceController.shared.container.viewContext
            guard let results = try? context.fetch(request) else {
                return []
            }
            return results.compactMap { ExerciseSearchEntity(exercise: $0) }
        }
    }

    static var defaultQuery = Query()
    
    var displayRepresentation: DisplayRepresentation {
        let message = "Your last lift of \(String(message!.characters)) was on \(timestamp). You lifted \(sets) sets of \(reps) with \(weight) \(units)."
        return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: message))
    }

    let id = UUID()
    
    var title: String?
    var message: AttributedString?
    var mediaItems: [IntentFile]
    var entryDate: Date?
    var location: CLPlacemark?
    let reps: Int16
    let sets: Int16
    let weight: Float
    let timestamp: Date
    let units: String
    
    init?(exercise: Exercise) {
        if let last = exercise.lastLift, let lastDate = exercise.lastLiftDate {
            reps = last.reps
            sets = last.sets
            timestamp = lastDate
            units = Settings().units == .imperial ? String(localized: "pounds") : String(localized: "kilograms")
            weight = last.weight
            message = AttributedString(stringLiteral: exercise.name!)
        } else {
            return nil
        }
    }
}

@available(iOS 18.0, *)
struct ExerciseSearchShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: ExerciseSearchIntent(), phrases: [
            "Look up an exercise in \(.applicationName)",
            "Search in \(.applicationName)",
        ], shortTitle: "Search a lift", systemImageName: "scalemass.fill")
    }
}
