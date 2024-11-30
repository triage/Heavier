//
//  HeavierAppIntent.swift
//  HeavierAppIntent
//
//  Created by Eric Schulte on 11/17/24.
//

import AppIntents
import CoreLocation
import CoreData

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
        Summary("\(\.$message) \(\.$sets) sets of \(\.$reps) reps at \(\.$weight)")
    }
    
    var units: String {
        Settings().units == .imperial ? String(localized: "pounds") : String(localized: "kilograms")
    }
    
    struct ParamsResolved: Codable {
        let reps: Int?
        let sets: Int?
        let weight: Double?
        let name: String?
        let name_original: String?
    }
    
    func confirmationDialog(exercise: Exercise, units: String, reps: Int? = nil, sets: Int? = nil, weight: Double? = nil) -> String? {
        guard let name = exercise.name, let reps = reps, let sets = sets, let weight = weight else {
            return nil
        }
        return "Confirm \(name) \(sets) sets of \(reps) reps at \(weight) \(units)."
    }
    
    @MainActor
    func perform() async throws -> some ReturnsValue<LiftEntity> & ProvidesDialog {
        self.reps = nil
        self.sets = nil
        self.weight = nil
        self.name = nil
        let context = PersistenceController.shared.container.viewContext
        var exercise: Exercise!
        do {
            // try with chatgpt. If chatgpt fails for any reason, continue normally.
            if let parsed = await RecordLiftIntent.resolveParamsFromInput(String(message.characters)) {
                self.reps = parsed.reps
                self.sets = parsed.sets
                self.name = parsed.name
                self.weight = parsed.weight

                if let name = self.name {
                    exercise = try await RecordLiftIntent.resolveExercise(name: name, fuzzyMatchName: false, context: context, resolve: $message)
                    self.name = exercise.name!
                }
            }
        } catch {
            // noop - continue
        }
        
        if exercise == nil {
            exercise = try await RecordLiftIntent.resolveExercise(name: name ?? String(message.characters), fuzzyMatchName: true, context: context, resolve: $message)
            self.name = exercise.name!
        }
        
        if reps == nil {
            self.reps = try await $reps.requestValue("How many reps?")
        }

        if sets == nil {
            self.sets = try await $reps.requestValue("How many sets?")
        }
        
        if weight == nil {
            self.weight = try await $weight.requestValue("How much weight?")
        }
        
        guard let sets = sets, let reps = reps, let weight = weight else {
            throw AppIntentError.Unrecoverable.entityNotFound
        }
        
        guard let name = name, let confirmationDialog = confirmationDialog(exercise: exercise, units: units, reps: reps, sets: sets, weight: weight) else {
            throw AppIntentError.Unrecoverable.entityNotFound
        }
        
        let confirm = try await $name.requestConfirmation(for: name, dialog: IntentDialog(stringLiteral: confirmationDialog))
        
        if !confirm {
            throw RecordLiftIntentError.willNotCreate
        }
        
        let lift = Lift(context: context)
        lift.id = UUID()
        lift.timestamp = Date()
        lift.reps = Int16(reps)
        lift.sets = Int16(sets)
        lift.weight = Lift.normalize(weight: Float(weight))
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
