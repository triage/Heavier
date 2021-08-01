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
    @Published var sections: [LiftsSection] = []
    private let fetchedResultsController: NSFetchedResultsController<Lift>
    
    private init(fetchedResultsController: NSFetchedResultsController<Lift>) {
        self.fetchedResultsController = fetchedResultsController
        super.init()
        
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            lifts = fetchedResultsController.fetchedObjects ?? []
            if let sections = fetchedResultsController.sections {
                DispatchQueue.global().async {
                    let liftsSections = sections.map {
                        LiftsSection(section: $0)
                    }
                    DispatchQueue.main.async {
                        self.sections = liftsSections
                    }
                }

            }
        } catch {
            print("failed to fetch items!")
        }
    }
    
    convenience init(
        dateComponents: DateComponents,
        managedObjectContext: NSManagedObjectContext
    ) {
        self.init(fetchedResultsController: NSFetchedResultsController(
            fetchRequest: Lift.CoreData.fetchRequest(day: dateComponents)!,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: Lift.CoreData.KeyPath.exerciseId,
            cacheName: nil
        ))
    }
    
    convenience init(
        exercise: Exercise,
        dateComponents: DateComponents,
        managedObjectContext: NSManagedObjectContext
    ) {
        self.init(fetchedResultsController: NSFetchedResultsController(
            fetchRequest: Lift.CoreData.fetchRequest(exercise: exercise, ascending: true, day: dateComponents),
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: Lift.CoreData.KeyPath.exerciseId,
            cacheName: nil
        ))
    }
    
    convenience init(
        exercise: Exercise?,
        managedObjectContext: NSManagedObjectContext,
        ascending: Bool = true,
        sectionNameKeyPath: String = #keyPath(Lift.dayGroupingIdentifier)
    ) {
        self.init(fetchedResultsController: NSFetchedResultsController(
            fetchRequest: Lift.CoreData.fetchRequest(exercise: exercise, ascending: ascending),
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: sectionNameKeyPath,
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
        DispatchQueue.global().async {
            let liftsSections = sections.map {
                LiftsSection(section: $0)
            }
            DispatchQueue.main.async {
                self.sections = liftsSections
            }
        }
    }
}
