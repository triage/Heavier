//
//  RecordLiftIntent+ResolveParamsFromInput.swift
//  Heavier
//
//  Created by Eric Schulte on 11/28/24.
//

import Foundation
import AppIntents
import OpenAI

@available(iOS 18.0, *)
extension RecordLiftIntent {
    
    // todo: localize this
    static let inputSynonyms = [
        "dad left": "deadlift",
        "dead lift": "deadlift",
        "dad lift": "deadlift",
        "fun squad": "front squat",
        "groot kickback": "glute kickback",
        "blue kickback": "glute kickback",
        "glutes kickback": "glute kickback",
        "kick back": "kickback",
        "gluth": "glute",
        "glue": "glute",
        "lap pull": "lat pull"
    ]
    
    static func resolveParamsFromInput(_ _message: String) async throws -> ParamsResolved? {
        guard let apiKey = OpenAI.apiKey else {
            return nil
        }
        var message = _message
        RecordLiftIntent.inputSynonyms.forEach { key, value in
            message = message.lowercased().replacingOccurrences(of: key, with: value)
        }
        
        let configuration = OpenAI.Configuration(token: apiKey, organizationIdentifier: "org-XE7PEjugGNi7INrbnFUKmk3y", timeoutInterval: 60.0)
        let openAI = OpenAI(configuration: configuration)
        let prompt = """
        Weightlifting
        Analyze and respond in JSON: { weight, reps, sets, exercise }
        Remove plurals from the exercise name
        ---
        Example: "I did deadlift, 1 set of 10 at 225 pounds"
        Result: { weight: 225, sets: 1, reps: 10, exercise: "deadlift" }
        ---
        Example: "Leg press, 2 sets of 7 at 500 pounds"
        Result: { weight: 500, sets: 2, reps: 7, exercise: "Leg press" }
        ---
        Example: "5 reps of barbell bench press"
        Result: { weight: null, sets: null, reps: 5, exercise: "Barbell bench press" }
        ---
        Example: "10 pull-ups"
        Result: { weight: null, sets: 1, reps: 10, exercise: "pull-up" }
        ---
        Example: "2 sets of 20 push-ups"
        Result: { weight: null, sets: 2, reps: 20, exercise: "push-up" }
        =====
        \(message)
        """
        let query = ChatQuery(messages: [.init(role: .user, content: prompt)!], model: .gpt4_o_mini)
        do {
            let result = try await openAI.chats(query: query)
            guard let choice = result.choices.first, var content = choice.message.content?.string else {
                return nil
            }
            content = content.replacingOccurrences(of: "```json", with: "")
            content = content.replacingOccurrences(of: "```", with: "")
            let data = Data(content.utf8)
            let paramsResolved = try JSONDecoder().decode(ParamsResolved.self, from: data)
            print(paramsResolved)
            return paramsResolved
        } catch (let error) {
            throw error
        }
    }
}
