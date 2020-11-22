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
    private let fetchedResultsController: NSFetchedResultsController<Lift>
    
    init(exercise: Exercise) {
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: Lift.fetchRequest(exercise: exercise),
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            lifts = fetchedResultsController.fetchedObjects ?? []
        } catch {
            print("failed to fetch items!")
        }
    }
}

extension LiftsObservable: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let lifts = controller.fetchedObjects as? [Lift]
        else {
            return
            
        }
        self.lifts = lifts
    }
}
