//
//  HeavierAppIntent.swift
//  HeavierAppIntent
//
//  Created by Eric Schulte on 11/17/24.
//

import AppIntents

struct HeavierAppIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Record a lift"
    
    @Parameter(title: "Exercise Name")
    var name: String

    @Parameter(title: "Sets")
    var sets: Int

    @Parameter(title: "Reps")
    var reps: Int

    @Parameter(title: "Weight")
    var weight: Double
    
//    @Parameter(title: "Exercise")
//    var target: ExerciseEntity
    
    static var parameterSummary: some ParameterSummary {
        Summary("Record a lift for \(\.$name) - \(\.$sets) sets of \(\.$reps) at \(\.$weight)")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Print to indicate start
        print("Recording \(sets) sets of \(reps) \(name) with \(weight) pounds.")

        // Use performBackgroundTask for Core Data operations
        let persistentContainer = PersistenceController.shared.container
        let dialog: IntentDialog = try await withCheckedThrowingContinuation { continuation in
            persistentContainer.performBackgroundTask { context in
                do {
                    // Fetch request in the background context
                    let fetchRequest = Exercise.CoreData.searchFetchRequest(name)
                    let exercises = try context.fetch(fetchRequest) as [Exercise]
                    
                    if exercises.count == 1, let found = exercises.first {
                        print("one!")
                        // Create and configure the Lift object
                        let lift = Lift(context: context)
                        lift.id = UUID()
                        lift.timestamp = Date()
                        lift.reps = Int16(reps)
                        lift.sets = Int16(sets)
                        lift.exercise = found
                        try context.save() // Save changes on the background context
                        
                        // Create a LocalizedStringResource for dialog message
                        let message = "Recorded \(name) \(sets) sets of \(reps) with \(weight) pounds."
                        let dialog = IntentDialog(stringLiteral: message)
                        continuation.resume(returning: dialog)
                    } else if exercises.count > 1 {
                        let exactMatches = exercises.filter {
                            guard let foundName = $0.name else { return false }
                            return foundName.lowercased() == name.lowercased()
                        }
                        if exactMatches.count == 1, let found = exactMatches.first {
                            print("found exact match!")
                            let lift = Lift(context: context)
                            lift.timestamp = Date()
                            lift.id = UUID()
                            lift.reps = Int16(reps)
                            lift.sets = Int16(sets)
                            lift.exercise = found
                            try context.save()
                            
                            let message = "Recorded \(name) \(sets) sets of \(reps) with \(weight) pounds."
                            let dialog = IntentDialog(stringLiteral: message)
                            continuation.resume(returning: dialog)
                        } else {
                            print("more than one")
                            continuation.resume(returning: "foobar")
                        }
                    } else {
                        print("failed")
                        continuation.resume(returning: "foobar")
                    }
                } catch {
                    // Handle errors and resume the continuation with an error
                    print("Error during background task: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
        return .result(dialog: dialog)
    }

    
    static let openAppWhenRun: Bool = false
}

struct ExerciseEntity: AppEntity {
    static var defaultQuery: ExerciseEntityQuery = ExerciseEntityQuery()
    
    typealias DefaultQuery = ExerciseEntityQuery
    typealias ID = UUID

    let id: ID

    @Property(title: "Exercise name")
    var name: String
    
    init?(exercise: Exercise) {
        guard let id = exercise.id, let name = exercise.name else {
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

struct ExerciseEntityQuery: EntityQuery, DynamicOptionsProvider {
    func entities(for identifiers: [ExerciseEntity.ID]) async throws -> [ExerciseEntity] {
        // get exercises
        let results = try? PersistenceController.shared.container.viewContext.fetch(Exercise.CoreData.searchFetchRequest(nil))
        guard let results = results else {
            return [ExerciseEntity]()
        }
        return results.compactMap { (exercise: Exercise) -> ExerciseEntity? in
            return ExerciseEntity(exercise: exercise)
        }
    }
}

extension ExerciseEntityQuery: EnumerableEntityQuery {
    
    func allEntities() async throws -> [ExerciseEntity] {

        // get exercises
        let results = try? PersistenceController.shared.container.viewContext.fetch(Exercise.CoreData.searchFetchRequest(nil))
        guard let results = results else {
            return [ExerciseEntity]()
        }
        return results.compactMap { (exercise: Exercise) -> ExerciseEntity? in
            return ExerciseEntity(exercise: exercise)
        }
    }
}
