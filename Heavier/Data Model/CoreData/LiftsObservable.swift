//
//  LiftsObservable.swift
//  Overload
//
//  Created by Eric Schulte on 11/21/20.
//

import Foundation
import CoreData
import Combine

final class LiftsObservable: NSObject, ObservableObject, Publisher {
    
    typealias Output = Lift
    typealias Failure = Never
    
    // Subject to manage the sending of values
    private let liftSubject = PassthroughSubject<Output, Never>()
    
    // Conformance to Publisher
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        liftSubject.receive(subscriber: subscriber)
    }
    
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
        } catch { /* noop */}
    }
    
    convenience init(
        dateComponents: DateComponents,
        context managedObjectContext: NSManagedObjectContext
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
        context managedObjectContext: NSManagedObjectContext
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
        context managedObjectContext: NSManagedObjectContext,
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath, let inserted = controller.object(at: newIndexPath) as? Lift {
                print("inserted:\(inserted)")
                liftSubject.send(inserted)
                // Handle the inserted row here
            }
        default:
            break
        }
    }
}
