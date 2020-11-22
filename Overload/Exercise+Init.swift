//
//  Exercise+Create.swift
//  Overload
//
//  Created by Eric Schulte on 11/21/20.
//

import Foundation
import CoreData

extension Exercise {
    convenience init(name: String, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.init(context: context)
        self.name = name
        self.id = UUID()
        try! PersistenceController.shared.container.viewContext.save()
    }
}
