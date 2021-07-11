//
//  ExercisesObservable.swift
//  Heavier
//
//  Created by Eric Schulte on 7/7/21.
//

import Foundation
import CoreData

final class ExercisesObservable: NSObject, ObservableObject {
    @Published var exercises: [Exercise] = []
    private let fetchedResultsController: NSFetchedResultsController<Exercise>
    
    private init(fetchedResultsController: NSFetchedResultsController<Exercise>) {
        self.fetchedResultsController = fetchedResultsController
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

extension ExercisesObservable: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let exercises = controller.fetchedObjects as? [Exercise] else {
            return
        }
        self.exercises = exercises
    }
}
