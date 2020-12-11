//
//  Exercise+WillSave.swift
//  Overload
//
//  Created by Eric Schulte on 11/24/20.
//

import Foundation

extension Exercise {
    public override func willSave() {
        setPrimitiveValue(Date(), forKey: #keyPath(Exercise.timestamp))
        clearLastGroupShortDescriptionCache()
    }
}
