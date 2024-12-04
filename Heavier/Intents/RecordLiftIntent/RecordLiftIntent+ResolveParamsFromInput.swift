//
//  RecordLiftIntent+ResolveParamsFromInput.swift
//  Heavier
//
//  Created by Eric Schulte on 11/28/24.
//

import Foundation
import AppIntents
import FirebaseFunctions

@available(iOS 18.0, *)
extension RecordLiftIntent {
    
    static func resolveParamsFromInput(_ message: String) async -> ParamsResolved? {
        do {
            let response = try await HeavierApp.functions.httpsCallable("lift_resolve_params").call(["query": message])
            guard let exerciseDict = response.data as? [String: Any] else {
                return nil
            }
            print("resolved: \(exerciseDict)")
            let data = try JSONSerialization.data(withJSONObject: exerciseDict, options: [])
            let resolved = try JSONDecoder().decode(ParamsResolved.self, from: data)
            return resolved
        } catch(let error) {
            print("error:\(error)")
            /* noop */
        }
        return nil
    }
}
