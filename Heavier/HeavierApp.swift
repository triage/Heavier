//
//  OverloadApp.swift
//  Overload
//
//  Created by Eric Schulte on 9/22/20.
//

import SwiftUI

@main
struct HeavierApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
