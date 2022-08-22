//
//  Exercise+Create.swift
//  Overload
//
//  Created by Eric Schulte on 11/21/20.
//

import Foundation
import CoreData

extension Exercise {
    convenience init?(
        name: String,
        relevance: Int,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.name = name
        self.relevance = Int16(relevance)
        self.id = UUID()
    }
}
