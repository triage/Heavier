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
struct HeavierAppIntent {
    
    static var title: LocalizedStringResource = "Record a lift!"

    @Parameter(title: "Title")
    var title: String?
    
    @Parameter(title: "Message")
    var message: AttributedString
    
    @Parameter(title: "Files")
    var mediaItems: [IntentFile]
    
    @Parameter(title: "Date")
    var entryDate: Date?
    
    @Parameter(title: "Location")
    var location: CLPlacemark?
    
    @Parameter(title: "Exercise Name")
    var exercise: ExerciseEntity?
    
    @Parameter(title: "Sets")
    var sets: Int?
    
    @Parameter(title: "Reps")
    var reps: Int?
    
    @Parameter(title: "Weight")
    var weight: Double?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Record a lift for \(\.$exercise) - \(\.$sets) sets of \(\.$reps) at \(\.$weight)")
    }
    
    func perform() async throws -> some ReturnsValue<LiftEntity> {
        // Print to indicate start
        guard let sets = sets, let reps = reps, let weight = weight, let exercise = exercise else {
            throw AppIntentError.restartPerform
        }
        print("Recording \(sets) sets of \(reps) \(exercise) with \(weight) pounds.")
        
        // Use performBackgroundTask for Core Data operations
        let persistentContainer = PersistenceController.shared.container
        let entry: LiftEntity? = try await withCheckedThrowingContinuation { continuation in
            persistentContainer.performBackgroundTask { context in
                do {
                    guard let foundExerciseWithUUID = Exercise.CoreData.fetch(with: exercise.id, context: context) else {
                        return
                    }
                    
                    print("one!")
                    // Create and configure the Lift object
                    let lift = Lift(context: context)
                    lift.id = UUID()
                    lift.timestamp = Date()
                    lift.reps = Int16(reps)
                    lift.sets = Int16(sets)
                    lift.exercise = foundExerciseWithUUID
                    try context.save() // Save changes on the background context
                    
                    // Create a LocalizedStringResource for dialog message
                    continuation.resume(returning: LiftEntity(lift: lift))
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
        let message = "Recorded \(exercise!.name!) \(sets) sets of \(reps) with \(weight) pounds."
        return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: message))
    }
}

@available(iOS 18.0, *)
@AssistantEntity(schema: .journal.entry)
struct LiftEntity {
    struct Query: EntityStringQuery {
        func entities(for identifiers: [LiftEntity.ID]) async throws -> [LiftEntity] { [] }
        func entities(matching string: String) async throws -> [LiftEntity] { [] }
    }
    
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
        message.append(bolded("\(lift.weight) pounds"))
        self.message = message
        
    }
    
    func bolded(_ string: String) -> AttributedString {
        var attributedString = AttributedString(string)
        var container = AttributeContainer()
        container[AttributeScopes.SwiftUIAttributes.FontAttribute.self] = .body.weight(.bold)
        attributedString.mergeAttributes(container, mergePolicy: .keepNew)
        return attributedString
    }

    static var defaultQuery = Query()
    var displayRepresentation: DisplayRepresentation { "Provide a display representation." }
    let id: UUID
    var title: String?
    var message: AttributedString?
    var mediaItems: [IntentFile]
    var entryDate: Date?
    var location: CLPlacemark?
}

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
            return [ExerciseEntity]()
        }
        return results.compactMap { (exercise: Exercise) -> ExerciseEntity? in
            return ExerciseEntity(exercise: exercise)
        }
    }
}

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
        AppShortcut(intent: HeavierAppIntent(), phrases: [
            "Record a lift in \(.applicationName)",
            "Log in \(.applicationName)",
        ], shortTitle: "Record a lift", systemImageName: "scalemass.fill")
    }
}
