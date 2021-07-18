//
//  LiftsSection.swift
//  Heavier
//
//  Created by Eric Schulte on 1/14/21.
//

import Foundation
import CoreData

class LiftsSection: NSFetchedResultsSectionInfo, Equatable, ObservableObject {
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
        self.groups = lifts?.groupedByWeightAndReps.values.sorted { first, second in
            first.mostRecent.timestamp! < second.mostRecent.timestamp!
        }
    }
    
    var groups: [[Lift]]?
    
    var name: String
    
    var indexTitle: String?
    
    var numberOfObjects: Int
    
    var objects: [Any]?
    
    var lifts: [Lift]? {
        return objects as? [Lift]
    }
}

extension LiftsSection: Identifiable {
    // swiftlint:disable:next identifier_name
    var id: String {
        guard let objects = objects,
              let first = (objects.first as? Lift)?.timestamp,
              let last = (objects.last as? Lift)?.timestamp else {
//              let hashValue = lifts?.identifiableHashValue else {
            return ""
        }
//        return "\(first) - \(last) - \(hashValue)"
        return "\(first) - \(last)"
    }
}
