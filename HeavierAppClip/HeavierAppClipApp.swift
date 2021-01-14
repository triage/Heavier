//
//  HeavierAppClipApp.swift
//  HeavierAppClip
//
//  Created by Eric Schulte on 12/28/20.
//

import SwiftUI

@main
struct HeavierAppClipApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
