//
//  OverloadApp.swift
//  Overload
//
//  Created by Eric Schulte on 9/22/20.
//

import SwiftUI
import Firebase
import OpenAI
import Firebase
import FirebaseFunctions

@main
struct HeavierApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase

    static let functions = Functions.functions()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    FirebaseApp.configure()
                }
            }
        }
    }
