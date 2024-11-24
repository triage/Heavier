//
//  SearchLiftIntent.swift
//  Heavier
//
//  Created by Eric Schulte on 11/24/24.
//

import Foundation
import AppIntents

@available(iOS 18.0, *)
@AssistantIntent(schema: .journal.search)
struct SearchLiftIntent: AppIntent {
    typealias PerformResult = <#type#>
    
    func perform() async throws -> some ReturnsValue<ExerciseSearchEntity> {
        
    }
    
    typealias SummaryContent = <#type#>
    
    
}
