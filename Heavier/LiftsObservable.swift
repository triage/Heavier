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
            print(sections.compactMap {
                $0.name
            })
        } catch {
            print("failed to fetch items!")
        }
    }
    
    convenience init(dateComponents: DateComponents) {
        self.init(fetchedResultsController: NSFetchedResultsController(
            fetchRequest: Lift.CoreData.fetchRequest(day: dateComponents)!,
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: Lift.CoreData.KeyPath.exerciseId,
            cacheName: nil
        ))
    }
    
    convenience init(exercise: Exercise?, ascending: Bool = true) {
        self.init(fetchedResultsController: NSFetchedResultsController(
            fetchRequest: Lift.CoreData.fetchRequest(exercise: exercise, ascending: ascending),
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: #keyPath(Lift.dayGroupingIdentifier),
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
