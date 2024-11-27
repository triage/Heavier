//
//  HeavierAppIntent.swift
//  HeavierAppIntent
//
//  Created by Eric Schulte on 11/17/24.
//

import AppIntents
import CoreLocation
import CoreData

enum RecordLiftError: Error, CustomLocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource {
        LocalizedStringResource(stringLiteral: description)
    }
    
    var description: String {
        String(localized: "OK! We won't create this exercise")
    }
    
    case willNotCreate
}

import NaturalLanguage
import CoreML

struct RecordLiftParamResolver {
    
    enum RecordLiftParamResolverError: Error {
        case keyNotFound
    }
    
    static func model<Root, Value>(for keyPath: KeyPath<Root, Value>) throws -> MLModel {
        switch keyPath {
        case \RecordLiftIntent.$weight:
            return try WeightClassifier(configuration: MLModelConfiguration()).model
        case \RecordLiftIntent.$sets:
            return try SetsClassifier(configuration: MLModelConfiguration()).model
        case \RecordLiftIntent.$reps:
            return try RepsClassifier(configuration: MLModelConfiguration()).model
        case \RecordLiftIntent.$name:
            return try NameClassifier(configuration: MLModelConfiguration()).model
        default:
            throw RecordLiftParamResolverError.keyNotFound
        }
    }

    static func resolveValue<Root, T>(for keyPath: KeyPath<Root, IntentParameter<T?>>, message: String) throws -> T? {
        let model = try RecordLiftParamResolver.model(for: keyPath)
        let predictor = try NLModel(mlModel: model)
        let label = predictor.predictedLabel(for: message)
        if let label = label as? T {
            return label
        } else if let label = label {
            let numberFormatter = NumberFormatter()
            if let valueAsNumber = numberFormatter.number(from: message) as? T {
                return valueAsNumber
            }
        }
        return label as? T
    }
}

@available(iOS 18.0, *)
@AssistantIntent(schema: .journal.createEntry)
struct RecordLiftIntent: AppIntent {
    var value: Never?
    
    static var title: LocalizedStringResource = "Record a lift"

    var title: String?
    
    @Parameter(title: "Exercise", description: "What exercise?")
    var message: AttributedString
    
    @Parameter(default: [])
    var mediaItems: [IntentFile]
    
    @Parameter(default: Date())
    var entryDate: Date?
    
    @Parameter
    var location: CLPlacemark?

    @Parameter(title: "Name", description: "Exercise name")
    var name: String?
    
    @Parameter(title: "Sets", description: "The number of sets")
    var sets: Int?
    
    @Parameter(title: "Reps", description: "The number of reps")
    var reps: Int?
    
    @Parameter(title: "Weight", description: "The amount of weight lifted")
    var weight: Double?
    
    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$message) \(\.$sets) sets of \(\.$reps) at \(\.$weight)")
    }
    
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
                exercise.name = String(name)
                exercise.id = UUID()
                return exercise
            } else {
                throw RecordLiftError.willNotCreate
            }
        } else {
            return nil
        }
    }
    
    struct ParamsResolved {
        let reps: Int?
        let sets: Int?
        let weight: Double?
        let name: String?
    }
    
    static func resolveParamsFromInput(_ message: String) throws -> ParamsResolved? {
        let reps = try? RecordLiftParamResolver.resolveValue(for: \RecordLiftIntent.$reps, message: message)
        let sets = try? RecordLiftParamResolver.resolveValue(for: \RecordLiftIntent.$sets, message: message)
        let weight = try? RecordLiftParamResolver.resolveValue(for: \RecordLiftIntent.$weight, message: message)
        let name = try? RecordLiftParamResolver.resolveValue(for: \RecordLiftIntent.$name, message: message)
        return ParamsResolved(reps: reps, sets: sets, weight: weight, name: nil)
    }
    
    @MainActor
    func perform() async throws -> some ReturnsValue<LiftEntity> & ProvidesDialog {
        let context = PersistenceController.shared.container.viewContext
        guard let exercise = try await RecordLiftIntent.resolveExercise(name: String(message.characters), context: context, resolve: $message) else {
            throw AppIntentError.Unrecoverable.unknown
        }
        self.message = AttributedString(exercise.name!)
        
        if reps == nil {
            let reps = try await $reps.requestValue("How many reps?")
            self.reps = reps
        }

        if sets == nil {
            let sets = try await $reps.requestValue("How many sets?")
            self.sets = sets
        }
        
        if weight == nil {
            let weight = try await $reps.requestValue("How much weight?")
            let weightNormalized = Lift.normalize(weight: Float(weight))
            self.weight = Double(weightNormalized)
        }
        
        guard let sets = sets, let reps = reps, let weight = weight else {
            throw AppIntentError.Unrecoverable.entityNotFound
        }
        
        let lift = Lift(context: context)
        lift.id = UUID()
        lift.timestamp = Date()
        lift.reps = Int16(reps)
        lift.sets = Int16(sets)
        lift.weight = Float(weight)
        lift.exercise = exercise
        try context.save() // Save changes on the background context
        
        if let entity = LiftEntity(lift: lift, context: .record) {
            return .result(value: entity, dialog: IntentDialog(entity.displayRepresentation.title))
            
        } else {
            throw AppIntentError.Unrecoverable.unknown
        }
    }

    static let openAppWhenRun: Bool = false
}

@available(iOS 18.0, *)
@AssistantEntity(schema: .journal.entry)
struct LiftEntity {
    
    enum Context {
        case record
        case searchFound
        case searchNotFound
        case exerciseNotFound
    }
    
    static var defaultQuery = Query()
    var displayRepresentation: DisplayRepresentation {
        switch context {
        case .record:
            if let reps = reps, let sets = sets, let weight = weight, let units = units, let message = message {
                let message = "Recorded \(String(message.characters)) \(sets) sets of \(reps) with \(weight) \(units)."
                return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: message))
            }
        case .searchFound:
            if let reps = reps, let sets = sets, let weight = weight, let units = units, let message = message {
                let message = "Your most recent lift of \(String(message.characters)) was on \(entryDate!). You did \(sets) sets of \(reps) with \(weight) \(units)."
                return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: message))
            }
        case .searchNotFound:
            if let message = message {
                return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: String(localized: "We were unable to find a recent lift for \(message)")))
            }
        case .exerciseNotFound:
            if let query = query {
                return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: String(localized: "We were unable to find any lift for \(query)")))
            }
        }
        return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: String(localized: "Something went wrong")))
    }
    let id: UUID
    var title: String?
    var message: AttributedString?
    let sets: Int16?
    let reps: Int16?
    let weight: Float?
    let units: String?
    let context: Context
    let query: String?
    
    var mediaItems: [IntentFile]
    var entryDate: Date?
    var location: CLPlacemark?
    
    
    struct Query: EntityStringQuery {
        func entities(for identifiers: [LiftEntity.ID]) async throws -> [LiftEntity] {
            let request = Exercise.CoreData.matchingIdentifiers(identifiers)
            let context = PersistenceController.shared.container.viewContext
            guard let results = try? context.fetch(request) else {
                return []
            }
            return results.compactMap { LiftEntity(exercise: $0) }
        }
        func entities(matching string: String) async throws -> [LiftEntity] {
            let request = Exercise.CoreData.searchFetchRequest(string)
            let context = PersistenceController.shared.container.viewContext
            guard let results = try? context.fetch(request) else {
                return []
            }
            return results.compactMap { LiftEntity(exercise: $0) }
        }
    }
    
    init(failedQuery: String) {
        id = UUID()
        context = .searchNotFound
        sets = nil
        reps = nil
        units = nil
        weight = nil
        query = failedQuery
        message = .init(localized: "No lifts found")
        entryDate = nil
    }
    
    init(exercise: Exercise) {
        if let lift = exercise.lastLift, let name = exercise.name, let id = lift.id {
            self.id = id
            context = .searchFound
            reps = lift.reps
            sets = lift.sets
            weight = lift.weightLocalized.weight
            units = Settings().units == .imperial ? String(localized: "pounds") : String(localized: "kilograms")
            query = nil
            entryDate = lift.timestamp
            message = AttributedString(name)
            mediaItems = []
        } else {
            id = UUID()
            context = .searchNotFound
            sets = nil
            reps = nil
            units = nil
            weight = nil
            query = nil
            message = .init(localized: "No lifts found")
            entryDate = nil
        }
    }
    
    init?(lift: Lift, context _context: Context) {
        guard let id = lift.id, let exercise = lift.exercise, let name = exercise.name else {
            return nil
        }
        self.id = id
        context = _context
        reps = lift.reps
        sets = lift.sets
        weight = lift.weightLocalized.weight
        units = Settings().units == .imperial ? String(localized: "pounds") : String(localized: "kilograms")
        query = nil
        entryDate = lift.timestamp
        message = AttributedString(name)
        mediaItems = []
    }
}

@available(iOS 18.0, *)
struct LiftShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: RecordLiftIntent(), phrases: [
            "Record a lift in \(.applicationName)",
            "Log in \(.applicationName)",
            "\(.applicationName), record",
        ], shortTitle: "Record a lift", systemImageName: "scalemass.fill")
        
        AppShortcut(intent: ExerciseSearchIntent(), phrases: [
            "Look up an exercise in \(.applicationName)",
            "Find a lift in \(.applicationName)",
            "Find an exercise in \(.applicationName)",
            "Search in \(.applicationName)",
        ], shortTitle: "Search a lift", systemImageName: "magnifyingglass")
    }
}
