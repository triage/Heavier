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
    private var hashValue: String!
    init(section: NSFetchedResultsSectionInfo) {
        exercise = (section.objects!.first as! Lift).exercise!
        self.name = section.name
        self.indexTitle = section.indexTitle
        self.numberOfObjects = section.numberOfObjects
        self.objects = section.objects
        self.hashValue = self.computeHashValue()
        self.groups = lifts?.groupedByWeightAndReps.values.sorted { first, second in
            first.mostRecent.timestamp! < second.mostRecent.timestamp!
        }
    }
    
    private func computeHashValue() -> String {
        guard let lifts = objects as? [Lift],
              let first = (lifts.first)?.timestamp,
              let last = (lifts.last)?.timestamp else {
            return ""
        }
        let hashValue = lifts.identifiableHashValue
        return "\(first) - \(last) - \(hashValue)"
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
        hashValue
    }
}
