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
    
    func perform() async throws -> some IntentResult {
        print("term:\(criteria.term)")
        return .result()
    }
}

//
//@AssistantEntity(schema: .journal.entry)
//struct LiftSearchEntity {
//    
//    enum Context {
//        case record
//        case searchFound
//        case searchNotFound
//        case exerciseNotFound
//    }
//    
//    static var defaultQuery = Query()
//    var displayRepresentation: DisplayRepresentation {
//        switch context {
//        case .record:
//            if let reps = reps, let sets = sets, let weight = weight, let units = units, let message = message {
//                let message = "Recorded \(String(message.characters)) \(sets) sets of \(reps) with \(weight) \(units)."
//                return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: message))
//            }
//        case .searchFound:
//            if let reps = reps, let sets = sets, let weight = weight, let units = units, let message = message {
//                let message = "Your most recent lift of \(String(message.characters)) was on \(entryDate!). You did \(sets) sets of \(reps) with \(weight) \(units)."
//                return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: message))
//            }
//        case .searchNotFound:
//            if let message = message {
//                return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: String(localized: "We were unable to find a recent lift for \(message)")))
//            }
//        case .exerciseNotFound:
//            if let query = query {
//                return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: String(localized: "We were unable to find any lift for \(query)")))
//            }
//        }
//        return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: String(localized: "Something went wrong")))
//    }
//    let id: UUID
//    var title: String?
//    var message: AttributedString?
//    let sets: Int16?
//    let reps: Int16?
//    let weight: Float?
//    let units: String?
//    let context: Context
//    let query: String?
//    
//    var mediaItems: [IntentFile]
//    var entryDate: Date?
//    var location: CLPlacemark?
//    
//    
//    struct Query: EntityStringQuery {
//        func entities(for identifiers: [LiftEntity.ID]) async throws -> [LiftEntity] {
//            let request = Exercise.CoreData.matchingIdentifiers(identifiers)
//            let context = PersistenceController.shared.container.viewContext
//            guard let results = try? context.fetch(request) else {
//                return []
//            }
//            return results.compactMap { LiftEntity(exercise: $0) }
//        }
//        func entities(matching string: String) async throws -> [LiftEntity] {
//            let request = Exercise.CoreData.searchFetchRequest(string)
//            let context = PersistenceController.shared.container.viewContext
//            guard let results = try? context.fetch(request) else {
//                return []
//            }
//            return results.compactMap { LiftEntity(exercise: $0) }
//        }
//    }
//    
//    init(failedQuery: String) {
//        id = UUID()
//        context = .searchNotFound
//        sets = nil
//        reps = nil
//        units = nil
//        weight = nil
//        query = failedQuery
//        message = .init(localized: "No lifts found")
//        entryDate = nil
//    }
//    
//    init(exercise: Exercise) {
//        if let lift = exercise.lastLift, let name = exercise.name, let id = lift.id {
//            self.id = id
//            context = .searchFound
//            reps = lift.reps
//            sets = lift.sets
//            weight = lift.weightLocalized.weight
//            units = Settings().units == .imperial ? String(localized: "pounds") : String(localized: "kilograms")
//            query = nil
//            entryDate = lift.timestamp
//            message = AttributedString(name)
//            mediaItems = []
//        } else {
//            id = UUID()
//            context = .searchNotFound
//            sets = nil
//            reps = nil
//            units = nil
//            weight = nil
//            query = nil
//            message = .init(localized: "No lifts found")
//            entryDate = nil
//        }
//    }
//    
//    init?(lift: Lift, context _context: Context) {
//        guard let id = lift.id, let exercise = lift.exercise, let name = exercise.name else {
//            return nil
//        }
//        self.id = id
//        context = _context
//        reps = lift.reps
//        sets = lift.sets
//        weight = lift.weightLocalized.weight
//        units = Settings().units == .imperial ? String(localized: "pounds") : String(localized: "kilograms")
//        query = nil
//        entryDate = lift.timestamp
//        message = AttributedString(name)
//        mediaItems = []
//    }
//}
