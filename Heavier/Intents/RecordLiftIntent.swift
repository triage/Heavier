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
    
    static func resolveExercise(name: String, context: NSManagedObjectContext, resolve: IntentParameter<AttributedString>) async throws -> Exercise? {
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
            }, dialog: IntentDialog("We found a few results for \(name). Which one do you want to use?"))
            print("disambiguated: \(disambiguated)")
            if let found = try? Exercise.CoreData.findExactMatch(name: String(disambiguated.characters), caseSensitive: true, context: context) {
                print("returning exact match from disambiguity")
                print("found:\(found)")
                return found
            }
        }
        if matches.count == 0 {
            let shouldCreate = try await resolve.requestConfirmation(for: AttributedString(name), dialog: IntentDialog(stringLiteral: String(localized: "Create a new exercise for \(name)?")))
            if shouldCreate {
                print("create!")
                let exercise = Exercise(context: context)
                exercise.name = String(name)
                exercise.id = UUID()
                return exercise
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    @MainActor
    func perform() async throws -> some ReturnsValue<LiftEntity> {
        // Print to indicate start
        print("omfggg!!gg")
        print("\(message) sets:\(sets ?? -1) reps:\(reps ?? -1) weight:\(weight ?? -1)")
        
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
        
        print("saved")
        if let entity = LiftEntity(lift: lift) {
            print("partyyyyyyy")
            return .result(value: entity, dialog: IntentDialog(entity.displayRepresentation.title))
            
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
        let message = "Recorded \(String(message!.characters)) \(sets) sets of \(reps) with \(weight) \(units)."
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
struct LiftShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: RecordLiftIntent(), phrases: [
            "Record a lift in \(.applicationName)",
            "\(.applicationName), record",
        ], shortTitle: "Record a lift", systemImageName: "scalemass.fill")
    }
}
