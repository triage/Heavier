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
    
    static var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter
    }
    
    static func localizedDateFormatter(for date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: date)
        
        // Extract month and day as Int
        guard let month = components.month, let day = components.day else {
            return ""
        }
        
        // Get the month name
         let monthFormatter = DateFormatter()
         monthFormatter.dateFormat = "MMMM"
         monthFormatter.locale = Locale.current
         let monthName = monthFormatter.monthSymbols[month - 1] // Adjust for 0-based index
         
         // Get the ordinal day
         let numberFormatter = NumberFormatter()
         numberFormatter.numberStyle = .ordinal
         numberFormatter.locale = Locale.current
         let ordinalDay = numberFormatter.string(from: NSNumber(value: day)) ?? "\(day)"
         
         // Combine month and ordinal day
         let localizedFormat = DateFormatter.dateFormat(fromTemplate: "MMMMd", options: 0, locale: Locale.current) ?? "MMMM d"
         if localizedFormat.contains("dMMMM") {
             return "\(ordinalDay) \(monthName)" // e.g., "2nd January"
         } else {
             return "\(monthName) \(ordinalDay)" // e.g., "January 2nd"
         }
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM dd")
        dateFormatter.timeStyle = .none
        return dateFormatter
    }
    
    static var defaultQuery = Query()
    var displayRepresentation: DisplayRepresentation {
        switch context {
        case .record:
            if let reps = reps,
               let sets = sets,
               let weight = weight,
               let weightLocalized = Lift.localize(weight: weight),
               let weightFormatted = LiftEntity.numberFormatter.string(from: weightLocalized as NSNumber),
               let units = units,
               let message = message {
                var volumeMessage: String = ""
                if let dailyVolume = dailyVolume, let volumeFormatted = LiftEntity.numberFormatter.string(from: dailyVolume as NSNumber) {
                    volumeMessage = ", for a total of \(volumeFormatted) \(units)"
                }
                
                var message = "Recorded \(String(message.characters)) \(sets) sets of \(reps) at \(weightFormatted) \(units)\(volumeMessage)."
                if let previousDate = previousDate,
                   let volume = Lift.localize(weight: previousDate.volume),
                   let volumeMessage = LiftEntity.numberFormatter.string(from: volume as NSNumber) {
                    let dateFormatted = LiftEntity.localizedDateFormatter(for: previousDate.date)
                    let previousMessage = "On \(dateFormatted), you did \(volumeMessage) solid ass \(units). Light weight, baby!"
                    message.append("\n\(previousMessage)")
                }
                return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: message))
            }
        case .searchFound:
            if let reps = reps, let sets = sets, let weight = weight, let units = units, let message = message {
                let message = "Your most recent lift of \(String(message.characters)) was on \(entryDate!). You did \(sets) sets of \(reps) with \(String(describing: Lift.localize(weight: weight)))) \(units)."
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
