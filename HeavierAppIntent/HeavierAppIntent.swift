//
//  HeavierAppIntent.swift
//  HeavierAppIntent
//
//  Created by Eric Schulte on 11/17/24.
//

import AppIntents

@AssistantIntent(schema: .journal.createEntry)
struct HeavierAppIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Record a lift"
    
    @Parameter(title: "Exercise Name")
    var exercise: ExerciseEntity

    @Parameter(title: "Sets")
    var sets: Int

    @Parameter(title: "Reps")
    var reps: Int

    @Parameter(title: "Weight")
    var weight: Double
    
    static var parameterSummary: some ParameterSummary {
        Summary("Record a lift for \(\.$exercise) - \(\.$sets) sets of \(\.$reps) at \(\.$weight)")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Print to indicate start
        print("Recording \(sets) sets of \(reps) \(exercise) with \(weight) pounds.")

        // Use performBackgroundTask for Core Data operations
        let persistentContainer = PersistenceController.shared.container
        let dialog: IntentDialog = try await withCheckedThrowingContinuation { continuation in
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
                    let message = "Recorded \(exercise.name) \(sets) sets of \(reps) with \(weight) pounds."
                    let dialog = IntentDialog(stringLiteral: message)
                    continuation.resume(returning: dialog)
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

private extension Lift {
    var displayRepresentation: DisplayRepresentation {
        let message = "Recorded \(exercise!.name!) \(sets) sets of \(reps) with \(weight) pounds."
        return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: message))
    }
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
    static var sortingOptions = SortingOptions {
      SortableBy(\ExerciseEntity.$name)
    }
    
    static var properties = QueryProperties {
        Property(\ExerciseEntity.$name) {
            ContainsComparator { str in { (exercise: ExerciseEntity) in exercise.name.contains(str) } }
      }
    }
    
    func entities(
      matching comparators: [(ExerciseEntity) -> Bool],
      mode: ComparatorMode,
      sortedBy: [Sort<ExerciseEntity>],
      limit: Int?
    ) async throws -> [ExerciseEntity] {
//      books.filter { book in comparators.allSatisfy { comparator in comparator(book) } }
        let exercises = try? PersistenceController.shared.container.viewContext.fetch(Exercise.CoreData.searchFetchRequest(nil))
        guard let exercises = exercises else {
            return [ExerciseEntity]()
        }
//        return results.compactMap { (exercise: Exercise) -> ExerciseEntity? in
//            return ExerciseEntity(exercise: exercise)
//        }
        return exercises.filter { exercise in comparators.allSatisfy { comparator in comparator(ExerciseEntity(exercise: exercise)) } }
    }
}

struct LiftShortcus: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: HeavierAppIntent(), phrases: [
            "Record a lift in \(.applicationName)",
            "Log in \(.applicationName)",
        ], shortTitle: "Record a lift", systemImageName: "scalemass.fill")
    }
}
