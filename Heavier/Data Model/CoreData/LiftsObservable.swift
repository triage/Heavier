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
                self.sections = sections.map {
                    LiftsSection(section: $0)
                }
            }
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
    
    convenience init(exercise: Exercise?, ascending: Bool = true, sectionNameKeyPath: String = #keyPath(Lift.dayGroupingIdentifier)) {
        self.init(fetchedResultsController: NSFetchedResultsController(
            fetchRequest: Lift.CoreData.fetchRequest(exercise: exercise, ascending: ascending),
            managedObjectContext: PersistenceController.shared.container.viewContext,
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
        self.sections = sections.map {
            LiftsSection(section: $0)
        }
    }
}

class LiftsSection: NSFetchedResultsSectionInfo, Equatable {
    static func == (lhs: LiftsSection, rhs: LiftsSection) -> Bool {
        return lhs.name == rhs.name
    }
    
    let exercise: Exercise
    init(section: NSFetchedResultsSectionInfo) {
        exercise = (section.objects!.first as! Lift).exercise!
        self.name = section.name
        self.indexTitle = section.indexTitle
        self.numberOfObjects = section.numberOfObjects
        self.objects = section.objects
    }
    var name: String
    
    var indexTitle: String?
    
    var numberOfObjects: Int
    
    var objects: [Any]?
    
    var lifts: [Lift]? {
        return objects as? [Lift]
    }
}
