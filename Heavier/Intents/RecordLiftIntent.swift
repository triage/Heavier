//
//  HeavierAppIntent.swift
//  HeavierAppIntent
//
//  Created by Eric Schulte on 11/17/24.
//

import AppIntents
import CoreLocation
import CoreData

enum RecordLiftError: Error, CustomStringConvertible {
    var description: String {
        String(localized: "OK! We won't create this exercise")
    }
    
    case willNotCreate
}

@available(iOS 18.0, *)
@AssistantIntent(schema: .journal.createEntry)
struct RecordLiftIntent: AppIntent {
    
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

    @Parameter(title: "Sets", description: "The number of sets")
    var sets: Int?
    
    @Parameter(title: "Reps", description: "The number of reps")
    var reps: Int?
    
    @Parameter(title: "Weight", description: "The amount of weight lifted")
    var weight: Double?
    
    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$message) \(\.$sets) sets of \(\.$reps) at \(\.$weight)")
    }
    
    func resolveExerciseName(name: String, context: NSManagedObjectContext, resolve: IntentParameter<AttributedString>) async throws -> Exercise {
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
                AttributedString($0.name!)
            }, dialog: IntentDialog("We found a few results for \(message). Which one do you want to use?"))
            print("disambiguated: \(disambiguated)")
            if let found = try? Exercise.CoreData.findExactMatch(name: String(disambiguated.characters), caseSensitive: true, context: context) {
                print("returning exact match from disambiguity")
                print("found:\(found)")
                return found
            }
        }
        // no matches, we'll create an exercise for the user, (but confirm first)
        print("create?")
        if matches.count == 0 {
            let shouldCreate = try await resolve.requestConfirmation(for: AttributedString(name), dialog: IntentDialog(stringLiteral: String(localized: "Create a new exercise for \(message)?")))
            if shouldCreate {
                print("create!")
                let exercise = Exercise(context: context)
                exercise.name = String(message.characters)
                exercise.id = UUID()
                return exercise
            } else {
                throw RecordLiftError.willNotCreate
            }
        } else {
            print("don't create")
            throw AppIntentError.Unrecoverable.entityNotFound
        }
    }
    
    @MainActor
    func perform() async throws -> some ReturnsValue<LiftEntity> {
        // Print to indicate start
        print("omfggg!!gg")
        print("\(message) sets:\(sets ?? -1) reps:\(reps ?? -1) weight:\(weight ?? -1)")
        
        let context = PersistenceController.shared.container.viewContext
        let exercise = try await resolveExerciseName(name: String(message.characters), context: context, resolve: $message)
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
        
        print("saved")
        if let entity = LiftEntity(lift: lift) {
            print("partyyyyyyy")
            return .result(value: entity)
            
        } else {
            print("couldn't create entity")
            throw AppIntentError.Unrecoverable.unknown
        }
    }

    static let openAppWhenRun: Bool = false
}

@available(iOS 18.0, *)
@AssistantEntity(schema: .journal.entry)
struct LiftEntity {
    
    static var defaultQuery = Query()
    var displayRepresentation: DisplayRepresentation {
        let message = "Recorded \(String(message!.characters)) \(sets) sets of \(reps) with \(weight) kilograms."
        return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: message))
    }
    let id: UUID
    var title: String?
    var message: AttributedString?
    let sets: Int16
    let reps: Int16
    let weight: Float
    let units: String
    
    var mediaItems: [IntentFile]
    var entryDate: Date?
    var location: CLPlacemark?
    
    struct Query: EntityStringQuery {
        func entities(for identifiers: [LiftEntity.ID]) async throws -> [LiftEntity] { [] }
        func entities(matching string: String) async throws -> [LiftEntity] { [] }
    }
    
    init?(lift: Lift) {
        guard let id = lift.id, let exercise = lift.exercise, let name = exercise.name else {
            return nil
        }
        self.id = id
        reps = lift.reps
        sets = lift.sets
        weight = lift.weightLocalized.weight
        units = Settings().units == .imperial ? String(localized: "pounds") : String(localized: "kilograms")
        entryDate = lift.timestamp
        message = AttributedString(name)
        mediaItems = []
    }
}

@available(iOS 18.0, *)
struct ExerciseEntity: AppEntity {
    static var defaultQuery: ExerciseEntityQuery = ExerciseEntityQuery()
    
    typealias DefaultQuery = ExerciseEntityQuery
    typealias ID = UUID
    
    let id: ID
    
    @Property(title: "Exercise name")
    var name: String
    
    init?(exercise: Exercise) {
        guard let name = exercise.name, let id = exercise.id else {
            return nil
        }
        self.id = id
        self.name = name
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Exercise"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: name))
    }
}

@available(iOS 18.0, *)
struct ExerciseOptionsProvider: DynamicOptionsProvider {
    let query: String?
    
    init() {
        self.query = nil
    }
    
    init(query: String?) {
        self.query = query
    }
    
    func results() async throws -> [ExerciseEntity] {
        let results = try? PersistenceController.shared.container.viewContext.fetch(Exercise.CoreData.searchFetchRequest(nil))
        guard let results = results else {
            throw AppIntentError.Unrecoverable.entityNotFound
        }
        return results.compactMap { (exercise: Exercise) -> ExerciseEntity? in
            return ExerciseEntity(exercise: exercise)
        }
    }
}

@available(iOS 18.0, *)
struct ExerciseEntityQuery: EntityPropertyQuery {
    static var properties = EntityQueryProperties<ExerciseEntity, String> {
        Property(\.$name) {
            EqualToComparator { $0 }
            ContainsComparator { $0 }
        }
    }
    
    static var sortingOptions = SortingOptions {
        SortableBy(\.$name)
    }
    
    func entities(for identifiers: [UUID]) async throws -> [ExerciseEntity] {
        do {
            let entities = try await ExerciseOptionsProvider().results()
            return entities.filter {
                identifiers.contains($0.id)
            }
        } catch {
            return []
        }
    }
    
    func entities(matching comparators: [String], mode: ComparatorMode, sortedBy: [Sort<ExerciseEntity>], limit: Int?) async throws -> [ExerciseEntity] {
        guard !comparators.isEmpty, let name = comparators.first else {
            return try await ExerciseOptionsProvider().results()
        }
        let entities = try await ExerciseOptionsProvider(query: name).results()
        return entities
    }
    
    func suggestedEntities() async throws -> [ExerciseEntity] {
        return try await ExerciseOptionsProvider().results()
    }
}

@available(iOS 18.0, *)
struct LiftShortcus: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: RecordLiftIntent(), phrases: [
            "Record a lift in \(.applicationName)",
            "\(.applicationName), record",
        ], shortTitle: "Record a lift", systemImageName: "scalemass.fill")
    }
}
