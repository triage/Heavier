//
//  Lift+FetchRequest.swift
//  Overload
//
//  Created by Eric Schulte on 11/21/20.
//

import Foundation
import CoreData
import SwiftUI

extension Lift {
    enum CoreData {
        enum KeyPath {
            static let exerciseId = "exercise.id"
        }
        
        enum SortDescriptor {
            static func timestamp(ascending: Bool) -> NSSortDescriptor {
                NSSortDescriptor(key: #keyPath(Lift.timestamp), ascending: ascending)
            }
            static func exercise(ascending: Bool) -> NSSortDescriptor {
                NSSortDescriptor(key: Lift.CoreData.KeyPath.exerciseId, ascending: ascending)
            }
        }
        
        enum Predicate {
            static func daySelected(_ daySelected: DateComponents) -> NSPredicate? {
                guard let range = daySelected.dayRange else {
                    return nil
                }
                return NSPredicate(format: "(timestamp >= %@) AND (timestamp <= %@)",
                            range.lowerBound as CVarArg,
                            range.upperBound as CVarArg
                )
            }
            static func exercise(_ exercise: Exercise) -> NSPredicate {
                NSPredicate(format: "exercise = %@", exercise as CVarArg)
            }
            
            static func reps(_ reps: Int16) -> NSPredicate {
                NSPredicate(format: "reps = %i", reps)
            }
            
            static func weight(_ weight: Float) -> NSPredicate {
                NSPredicate(format: "weight = %f", weight)
            }
            
            static func exerciseName(_ query: String?) -> NSPredicate? {
                guard let query = query, query.count > 0 else {
                    return nil
                }
                return NSPredicate(format: "exercise.name CONTAINS[c] %@", query as CVarArg)
            }
            
            static func timestampRange(_ range: ClosedRange<Date>) -> NSPredicate {
                NSPredicate(
                    format: "(timestamp >= %@) AND (timestamp <= %@)",
                    range.lowerBound as CVarArg, range.upperBound as CVarArg
                )
            }
        }
        
        static func fetchRequest(exercise: Exercise?, ascending: Bool) -> NSFetchRequest<Lift> {
            let fetchRequest: NSFetchRequest<Lift> = Lift.fetchRequest()
            if let exercise = exercise {
                fetchRequest.predicate = Lift.CoreData.Predicate.exercise(exercise)
            }
            fetchRequest.sortDescriptors = [
                Lift.CoreData.SortDescriptor.timestamp(ascending: ascending)
            ]
            return fetchRequest
        }
        
        static func fetchRequest(day dayComponents: DateComponents) -> NSFetchRequest<Lift>? {
            var day = dayComponents
            day.calendar = Calendar.current
            guard
                let date = day.date,
                let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
                    return nil
            }
            let range = Calendar.current.startOfDay(for: date)...endOfDay
            let fetchRequest: NSFetchRequest<Lift> = Lift.fetchRequest()
            fetchRequest.predicate = Lift.CoreData.Predicate.timestampRange(range)
            fetchRequest.sortDescriptors = [
                Lift.CoreData.SortDescriptor.exercise(ascending: true),
                Lift.CoreData.SortDescriptor.timestamp(ascending: true)
            ]
            fetchRequest.relationshipKeyPathsForPrefetching = [#keyPath(Lift.exercise)]
            return fetchRequest
        }

        static func searchFetchRequest(query: String?) -> FetchRequest<Lift> {
            let predicate = Lift.CoreData.Predicate.exerciseName(query)
            return FetchRequest<Lift>(
                entity: Lift.entity(),
                sortDescriptors: [
                    Lift.CoreData.SortDescriptor.timestamp(ascending: true)
                ],
                predicate: predicate, animation: .default
            )
        }
    }
}
