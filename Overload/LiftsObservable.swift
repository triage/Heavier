//
//  LiftsObservable.swift
//  Overload
//
//  Created by Eric Schulte on 11/21/20.
//

import Foundation
import CoreData

final class LiftsObservable: NSObject, ObservableObject {
    @Published var lifts: [Lift] = []
    @Published var sections: [NSFetchedResultsSectionInfo] = []
    private let fetchedResultsController: NSFetchedResultsController<Lift>
    
    private init(fetchedResultsController: NSFetchedResultsController<Lift>) {
        self.fetchedResultsController = fetchedResultsController
        super.init()
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            lifts = fetchedResultsController.fetchedObjects ?? []
            sections = fetchedResultsController.sections ?? []
        } catch {
            print("failed to fetch items!")
        }
    }
    
    convenience init(dateComponents: DateComponents) {
        self.init(fetchedResultsController: NSFetchedResultsController(
            fetchRequest: Lift.fetchRequest(day: dateComponents)!,
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: "exercise.name",
            cacheName: nil
        ))
    }
    
    convenience init(exercise: Exercise?) {
        self.init(fetchedResultsController: NSFetchedResultsController(
            fetchRequest: Lift.fetchRequest(exercise: exercise),
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: "day",
            cacheName: nil
        ))
    }
}

extension LiftsObservable: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let lifts = controller.fetchedObjects as? [Lift], let sections = controller.sections else {
            return
        }
        self.lifts = lifts
        self.sections = sections
    }
}
