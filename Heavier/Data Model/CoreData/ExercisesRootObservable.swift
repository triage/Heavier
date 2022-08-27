//
//  ExercisesObservable.swift
//  Heavier
//
//  Created by Eric on 8/25/22.
//

import Foundation
import CoreData
import Combine

final class ExercisesRootObservable: NSObject, ObservableObject {
    @Published var query: String? = nil
    private let fetchedResultsController: NSFetchedResultsController<Exercise>
    private var cancellable: AnyCancellable? = nil
    
    init(managedObjectContext: NSManagedObjectContext) {
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: Exercise.CoreData.searchFetchRequest(nil),
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: Lift.CoreData.KeyPath.exerciseId,
            cacheName: nil
        )
        super.init()
        cancellable = $query.sink { newValue in
            print("sink! \(Date())")
        }
    }
}
