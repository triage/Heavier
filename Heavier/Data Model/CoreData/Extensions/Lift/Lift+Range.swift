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
    
    private static func timestampValue(at expression: ExpressionType, managedObjectContext: NSManagedObjectContext) -> Date? {
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

        var timestamp: Date?

        do {
            if let result = try managedObjectContext.fetch(request)
                as? [[String: Date]], let dict = result.first {
                
                timestamp = dict[expression.rawValue]
                return timestamp
            }
        } catch {
            assertionFailure("Failed to fetch max timestamp with error = \(error)")
            return nil
        }
        return nil
    }
    
    static func timestampBounds(managedObjectContext: NSManagedObjectContext) -> ClosedRange<Date>? {
        guard let min = timestampValue(at: .min, managedObjectContext: managedObjectContext), let max = timestampValue(at: .max, managedObjectContext: managedObjectContext) else {
            return nil
        }
        return min...max
    }
    
    static func timestampBoundsMonth(managedObjectContext: NSManagedObjectContext) -> ClosedRange<Date>? {
        guard let min = timestampValue(at: .min, managedObjectContext: managedObjectContext), let max = timestampValue(at: .max, managedObjectContext: managedObjectContext) else {
            return nil
        }
        return min.startOfMonth...max.endOfMonth
    }
}
