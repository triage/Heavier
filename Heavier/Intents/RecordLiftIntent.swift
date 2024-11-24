//
//  HeavierAppIntent.swift
//  HeavierAppIntent
//
//  Created by Eric Schulte on 11/17/24.
//

import AppIntents
import CoreLocation

@available(iOS 18.0, *)
@AssistantIntent(schema: .journal.createEntry)
struct RecordLiftIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Record a lift!!!omfg!"

    var title: String?
    
    @Parameter(title: "Name", description: "What exercise?")
    var message: AttributedString
    
    @Parameter(default: [])
    var mediaItems: [IntentFile]
    
    @Parameter(default: Date())
    var entryDate: Date?
    
    @Parameter
    var location: CLPlacemark?
//
    @Parameter(title: "Sets", description: "The number of sets")
    var sets: Int?
//    
    @Parameter(title: "Reps", description: "The number of reps")
    var reps: Int?
    
    @Parameter(title: "Weight", description: "The amount of weight lifted")
    var weight: Double?
    
//    static var parameterSummary: some ParameterSummary {
//        Summary("\(\.$name) \(\.$sets) sets of \(\.$reps) at \(\.$weight)")
//        ParameterSummaryBuilder.buildExpression(ParameterSummary)
//    }
    
    @MainActor
    func perform() async throws -> some ReturnsValue<LiftEntity> {
        // Print to indicate start
        print("omfggg!!gg")
        print("\(message) sets:\(sets ?? -1) reps:\(reps ?? -1) weight:\(weight ?? -1)")
        
        if reps == nil {
            print("asking for reps")
//            throw $reps.requestValue("How many reps?")
            let reps = try await $reps.requestValue("How many reps?")
            print("got reps!\(reps)")
            self.reps = reps
        }
        
        if sets == nil {
//            throw $reps.requestValue("How many reps?")
            let sets = try await $reps.requestValue("How many sets?")
            print("got sets!\(sets)")
            self.sets = sets
        }
        
        if weight == nil {
//            throw $reps.requestValue("How many reps?")
            let weight = try await $reps.requestValue("How much weight?")
            print("got weight!\(weight)")
            
            let weightNormalized = Lift.normalize(weight: Float(weight))
            
            self.weight = Double(weightNormalized)
        }
        
//        return .result(value: LiftEntity(message: "foobar"))
        guard let sets = sets, let reps = reps, let weight = weight else {
            throw AppIntentError.Unrecoverable.entityNotFound
        }
//        print("Recording \(sets) sets of \(reps) \(exercise) with \(weight) pounds.")
//        
        // Use performBackgroundTask for Core Data operations
        
        
        let persistentContainer = PersistenceController.shared.container
        let entry: LiftEntity? = try await withCheckedThrowingContinuation { continuation in
            persistentContainer.performBackgroundTask { context in
                do {
                    let request = Exercise.CoreData.searchFetchRequest(String(message.characters))
                    guard let results = try? context.fetch(request) else {
                        throw AppIntentError.Unrecoverable.entityNotFound
                    }
                    if let first = results.first {
                        
                        print("one!")
                        // Create and configure the Lift object
                        let lift = Lift(context: context)
                        lift.id = UUID()
                        lift.timestamp = Date()
                        lift.reps = Int16(reps)
                        lift.sets = Int16(sets)
                        lift.weight = Float(weight)
                        lift.exercise = first
                        try context.save() // Save changes on the background context
                        
                        // Create a LocalizedStringResource for dialog message
                        continuation.resume(returning: LiftEntity(lift: lift))
                    } else if results.isEmpty {
                        let exercise = Exercise(context: context)
                        exercise.name = String(message.characters)
                        exercise.id = UUID()
                        let lift = Lift(context: context)
                        lift.id = UUID()
                        lift.timestamp = Date()
                        lift.reps = Int16(reps)
                        lift.sets = Int16(sets)
                        lift.weight = Float(weight)
                        lift.exercise = exercise
                        try context.save() // Save changes on the background context
                        
                        // Create a LocalizedStringResource for dialog message
                        continuation.resume(returning: LiftEntity(lift: lift))
                        
                    } else if results.count > 1 {
                        let disambiguated = try await $message.requestDisambiguation(among: results.map {
                            AttributedString($0.name!)
                        }, dialog: IntentDialog("We found a few results for \(message). Which one do you want to use?"))
                        
                        let request = Exercise.CoreData.searchFetchRequest(String(message.characters))
                        guard let results = try? context.fetch(request), let first = results.first else {
                            throw AppIntentError.Unrecoverable.entityNotFound
                        }
                        
                        let lift = Lift(context: context)
                        lift.id = UUID()
                        lift.timestamp = Date()
                        lift.reps = Int16(reps)
                        lift.sets = Int16(sets)
                        lift.weight = Float(weight)
                        lift.exercise = first
                        try context.save() // Save changes on the background context
                        
                        // Create a LocalizedStringResource for dialog message
                        continuation.resume(returning: LiftEntity(lift: lift))
                        
                    }
                } catch {
                    // Handle errors and resume the continuation with an error
                    print("Error during background task: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
        if let entry = entry {
            return .result(value: entry)
        } else {
            throw AppIntentError.restartPerform
        }
    }
    
    
    static let openAppWhenRun: Bool = false
}

private extension Lift {
    var displayRepresentation: DisplayRepresentation {
        let message = "Recorded \(exercise!.name!) \(sets) sets of \(reps) with \(weight) kilograms."
        return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: message))
    }
}

@available(iOS 18.0, *)
@AssistantEntity(schema: .journal.entry)
struct LiftEntity {
    
    static var defaultQuery = Query()
    var displayRepresentation: DisplayRepresentation { "Provide a display representation." }
    let id: UUID
    var title: String?
    var message: AttributedString?
    var mediaItems: [IntentFile]
    var entryDate: Date?
    var location: CLPlacemark?
    
    struct Query: EntityStringQuery {
        func entities(for identifiers: [LiftEntity.ID]) async throws -> [LiftEntity] { [] }
        func entities(matching string: String) async throws -> [LiftEntity] { [] }
    }
    
//    init(message: String) {
//        id = UUID()
//        self.message = AttributedString(stringLiteral: message)
//        entryDate = Date()
//        self.mediaItems = []
//    }
    
    init?(lift: Lift) {
        guard let id = lift.id, let exercise = lift.exercise, let name = exercise.name else {
            return nil
        }
        self.id = id
        entryDate = lift.timestamp
        var message = AttributedString(stringLiteral: "Recorded ")
        message.append(bolded(name))
        message.append(AttributedString(stringLiteral: ". "))
        message.append(bolded("\(lift.sets) sets"))
        message.append(AttributedString(stringLiteral: " of "))
        message.append(bolded("\(lift.reps) reps"))
        message.append(AttributedString(stringLiteral: " at "))
        message.append(bolded("\(lift.weightLocalized)"))
        self.message = message
        self.mediaItems = []
    }
    
    func bolded(_ string: String) -> AttributedString {
        var attributedString = AttributedString(string)
        var container = AttributeContainer()
        container[AttributeScopes.SwiftUIAttributes.FontAttribute.self] = .body.weight(.bold)
        attributedString.mergeAttributes(container, mergePolicy: .keepNew)
        return attributedString
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
