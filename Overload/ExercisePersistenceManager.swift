//
//  ExercisePersistenceManager.swift
//  Overload
//
//  Created by Eric Schulte on 10/15/20.
//

import Foundation
import CoreData

class ExercisePersistenceManager: NSObject, ObservableObject {
    @Published var exercises: [Exercise] = []
    private let fetchedResultsController: NSFetchedResultsController<Exercise>
    
    init(managedObjectContext: NSManagedObjectContext) {
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: Exercise.exercisesFetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            exercises = fetchedResultsController.fetchedObjects ?? []
        } catch {
            print("failed to fetch items!")
        }
    }
}

extension ExercisePersistenceManager: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let exercises = controller.fetchedObjects as? [Exercise] else {
            return
        }
        
        self.exercises = exercises
    }
}
