//
//  RecordLiftIntentError.swift
//  Heavier
//
//  Created by Eric Schulte on 11/28/24.
//

import Foundation

enum RecordLiftIntentError: Error, CustomLocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource {
        LocalizedStringResource(stringLiteral: description)
    }
    
    var description: String {
        String(localized: "OK")
    }
    
    case willNotCreate
}
