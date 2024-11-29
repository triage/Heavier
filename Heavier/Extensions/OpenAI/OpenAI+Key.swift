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
        Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String
    }
}
