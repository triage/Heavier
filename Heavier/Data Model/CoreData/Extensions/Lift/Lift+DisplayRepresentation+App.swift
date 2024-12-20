//
//  Lift+DisplayRepresentation.swift
//  Heavier
//
//  Created by Eric Schulte on 12/18/24.
//

import Foundation

extension Lift {
    
    var displayRepresentation: String? {
        
        guard let exercise = exercise, let name = exercise.name else {
            return nil
        }
        
        let boosts = [
            String(localized: "Nice job!"),
            String(localized: "Nice work!"),
            String(localized: "Congratulations!"),
            String(localized: "You did it!"),
            String(localized: "Light weight, baby!")
        ]
        
        let liftsToday = exercise.liftsToday()
        let dailyVolume = liftsToday?.volume
        var previousDate: LiftsOnDateSummary? = nil
        if let liftsOnPreviousDay = exercise.liftsOnPreviousDay() {
            previousDate = LiftsOnDateSummary(date: liftsOnPreviousDay.0, volume: liftsOnPreviousDay.1.volume)
        }
        
        let units = Settings().units == .imperial ? String(localized: "pounds") : String(localized: "kilograms")
        
        var volumeMessage: String = ""
        if let dailyVolume = dailyVolume,
           let dailyVolumeFormatted = NumberFormatter.Heavier.weightFormatter.string(from: Lift.localize(weight: dailyVolume) as NSNumber) {
            volumeMessage = String(localized: ", for a total daily volume of \(dailyVolumeFormatted) \(units)")
        }
        
        var message = String(localized: "Recorded \(name))\(volumeMessage).")
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
        return message
    }
}
