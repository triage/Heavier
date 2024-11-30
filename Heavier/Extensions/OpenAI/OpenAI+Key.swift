//
//  OpenAI+Key.swift
//  Heavier
//
//  Created by Eric Schulte on 11/28/24.
//

import Foundation
import OpenAI

extension OpenAI {
    static var apiKey: String? {
        if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return key
        }
        return nil
    }
}
