//
//  OverloadApp.swift
//  Overload
//
//  Created by Eric Schulte on 9/22/20.
//

import SwiftUI

@main
struct OverloadApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var exerciseStorage: ExercisePersistenceManager

    init() {
        let storage = ExercisePersistenceManager(managedObjectContext: persistenceController.container.viewContext)
        self._exerciseStorage = StateObject(wrappedValue: storage)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(exerciseStorage: exerciseStorage)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
