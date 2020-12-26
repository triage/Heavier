//
//  ObservableValue.swift
//  Heavier
//
//  Created by Eric Schulte on 12/26/20.
//

import Foundation
import Combine

class ObservableValue<Type: Any>: ObservableObject {
    @Published var value: Type
    init(value: Type) {
        self.value = value
    }
}
