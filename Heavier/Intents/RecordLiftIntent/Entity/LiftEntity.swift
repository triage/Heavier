//
//  LiftEntity.swift
//  Heavier
//
//  Created by Eric Schulte on 11/28/24.
//

import Foundation
import AppIntents
import CoreLocation

struct LiftsOnDateSummary {
    let date: Date
    let volume: Float
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
    
    struct LiftSummaryComparision {
        init(from: LiftEntity, previousDate: Date) {
            
        }
    }
    
    let boosts = [
        String(localized: "Nice job!"),
        String(localized: "Nice work!"),
        String(localized: "Congratulations!"),
        String(localized: "You did it!"),
        String(localized: "Light weight, baby!")
    ]
    
    static var defaultQuery = Query()
    var displayRepresentation: DisplayRepresentation {
        switch context {
        case .record:
            if let units = units,
               let message = message {
                var volumeMessage: String = ""
                if let dailyVolume = dailyVolume,
                   let dailyVolumeFormatted = NumberFormatter.Heavier.weightFormatter.string(from: Lift.localize(weight: dailyVolume) as NSNumber) {
                    volumeMessage = String(localized: ", for a total daily volume of \(dailyVolumeFormatted) \(units)")
                }
                
                var message = String(localized: "Recorded \(String(message.characters))\(volumeMessage).")
                if let previousDate = previousDate,
                   let dateFormatted = previousDate.date.localizedMonthDayRepresentation {
                    let previousDateVolume = Lift.localize(weight: previousDate.volume)
                    if let dailyVolume = dailyVolume {
                        let remaining = previousDate.volume - dailyVolume
                        if remaining > 0 {
                            if let volumeMessage = NumberFormatter.Heavier.weightFormatter.string(from: previousDateVolume as NSNumber) {
                                let previousMessage = String(localized: "On \(dateFormatted), you lifted \(volumeMessage) \(units).")
                                message.append("\n\(previousMessage)")
                                if let remainingFormatted = NumberFormatter.Heavier.weightFormatter.string(from: remaining as NSNumber) {
                                    message.append(String(localized: "\nYou have \(remainingFormatted) \(units) remaining."))
                                }
                            }
                        } else if
                            let excessFormatted = NumberFormatter.Heavier.weightFormatter.string(from: -1 * remaining as NSNumber),
                            let boost = boosts.randomElement() {
                            message.append(String(localized: "\n\(boost) You improved on your previous volume by \(excessFormatted) \(units)."))
                        }
                    }
                }
                return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: message))
            }
        case .searchFound:
            if let weight = weight, let weightFormatted = NumberFormatter.Heavier.weightFormatter.string(from: Lift.localize(weight: weight) as NSNumber) {
                if let reps = reps,
                   let sets = sets,
                   let units = units,
                   let message = message,
                   let entryDate = entryDate
                {
                    let dateFormatted = DateFormatter.Heaver.monthNameFormatter.string(from: entryDate)
                    let message = String(localized: "Your most recent lift of \(String(message.characters)) was on \(dateFormatted). You did \(sets) sets of \(reps) with \(weightFormatted) \(units).")
                    return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: message))
                }
            }
        case .searchNotFound:
            if let message = message {
                return DisplayRepresentation(title: LocalizedStringResource("We were unable to find a recent lift for \(message)"))
            }
        case .exerciseNotFound:
            if let query = query {
                return DisplayRepresentation(title: LocalizedStringResource("We were unable to find any lift for \(query)"))
            }
        }
        return DisplayRepresentation(title: LocalizedStringResource("Something went wrong"))
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
    let dailyVolume: Float?
    let previousDate: LiftsOnDateSummary?
    
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
        previousDate = nil
        dailyVolume = nil
        message = .init(localized: "No lifts found")
        entryDate = nil
    }
    
    init(exercise: Exercise) {
        if let lift = exercise.lastLift, let name = exercise.name, let id = lift.id {
            self.id = id
            context = .searchFound
            reps = lift.reps
            sets = lift.sets
            weight = lift.weight
            units = Settings().units == .imperial ? String(localized: "pounds") : String(localized: "kilograms")
            query = nil
            previousDate = nil
            dailyVolume = nil
            entryDate = lift.timestamp
            message = AttributedString(name)
            mediaItems = []
        } else {
            id = UUID()
            context = .searchNotFound
            sets = nil
            reps = nil
            previousDate = nil
            units = nil
            weight = nil
            dailyVolume = nil
            query = nil
            message = .init(localized: "No lifts found")
            entryDate = nil
        }
    }
    
    init?(lift: Lift, dailyVolume: Float?, previousDate: (Date, [Lift])?, context _context: Context) {
        guard let id = lift.id, let exercise = lift.exercise, let name = exercise.name else {
            return nil
        }
        self.id = id
        if let previousDate = previousDate {
            self.previousDate = LiftsOnDateSummary(date: previousDate.0, volume: previousDate.1.volume)
        } else {
            self.previousDate = nil
        }
        self.dailyVolume = dailyVolume
        context = _context
        reps = lift.reps
        sets = lift.sets
        weight = lift.weight
        units = Settings().units == .imperial ? String(localized: "pounds") : String(localized: "kilograms")
        query = nil
        entryDate = lift.timestamp
        message = AttributedString(name)
        mediaItems = []
    }
}
