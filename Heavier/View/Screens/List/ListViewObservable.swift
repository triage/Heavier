//
//  ListViewObservable.swift
//  Heavier
//
//  Created by Eric on 8/26/22.
//

import Foundation
import CoreData
import Combine

final class ListViewObservable: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var rows = [Exercise]()
    @Published var query: String = "" {
        didSet {
            fetchedResultsController.fetchRequest.predicate = Exercise.CoreData.predicate(query: query)
            fetchRows()
        }
    }
    
    private let fetchedResultsController: NSFetchedResultsController<Exercise>
    override init() {
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: Exercise.CoreData.searchFetchRequest(nil),
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        fetchedResultsController.delegate = self
        fetchRows()
    }
    
    func fetchRows() {
        do {
            try self.fetchedResultsController.performFetch()
            guard let exercises = fetchedResultsController.fetchedObjects else {
                return
            }
            sortExercises(exercises)
        } catch { }
    }
    
    func sortExercises(_ exercises: [Exercise]) {
        DispatchQueue.global().async {

            /*
             If there's a direct match, show that one first, followed by the others
             If there's not a direct match and the query length is > 0, show the "add new" cell, followed by the others
             Else, show all the exercises
             */
            var rows: [Exercise] = Array(exercises).sorted {
                if $0.lastLiftDate != nil && $1.lastLift == nil {
                    return true
                } else if $0.lastLiftDate == nil && $0.lastLiftDate != nil {
                    return false
                }
                guard let first = $0.lastLiftDate, let second = $1.lastLiftDate else {
                    return false
                }
                return first > second
            }
            if let directMatch: Exercise = exercises.first(where: { (exercise) -> Bool in
                exercise.name?.lowercased() == self.query.lowercased()
            }), let index = rows.firstIndex(of: directMatch) {
                // Found a direct match. Move it to first position.
                rows.move(fromOffsets: IndexSet(integer: index), toOffset: 0)
            } else if self.query.count > 0 {
                guard let placeholder = Exercise.createPlaceholderIfNecessary(context: PersistenceController.shared.container.viewContext) else {
                    fatalError("couldn't create placeholder Exercise")
                }
                placeholder.name = self.query
                rows.insert(placeholder, at: 0)
            }

            DispatchQueue.main.async {
                self.rows = rows
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let exercises = controller.fetchedObjects as? [Exercise] else {
            return
        }
        sortExercises(exercises)
    }
}
