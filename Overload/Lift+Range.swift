//
//  Lift+Range.swift
//  Overload
//
//  Created by Eric Schulte on 11/27/20.
//

import Foundation
import CoreData

extension Lift {
    
    private enum ExpressionType: String {
        case max = "max:"
        case min = "min:"
    }
    
    private static func timestampValue(at expression: ExpressionType) -> Date? {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        request.entity = Lift.entity()
        request.resultType = NSFetchRequestResultType.dictionaryResultType

        let keypathExpression = NSExpression(forKeyPath: "timestamp")
        let maxExpression = NSExpression(forFunction: expression.rawValue, arguments: [keypathExpression])

        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = expression.rawValue
        expressionDescription.expression = maxExpression
        expressionDescription.expressionResultType = .dateAttributeType
        
        request.propertiesToFetch = [expressionDescription]

        var timestamp: Date? = nil

        do {
            if let result = try PersistenceController.shared.container.viewContext.fetch(request) as? [[String: Date]], let dict = result.first {
                timestamp = dict[expression.rawValue]
                return timestamp
            }
        } catch {
            assertionFailure("Failed to fetch max timestamp with error = \(error)")
            return nil
        }
        return nil
    }
    
    static var timestampBounds: ClosedRange<Date>? {
        guard let min = timestampValue(at: .min), let max = timestampValue(at: .max) else {
            return nil
        }
        return min...max
    }
}
