//
//  OverloadApp.swift
//  Overload
//
//  Created by Eric Schulte on 9/22/20.
//

import SwiftUI
import Firebase
import OpenAI

@main
struct HeavierApp: App {
    let persistenceController = PersistenceController.shared
    let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY")
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    print("openapikey:\(OpenAI.apiKey)")
                    FirebaseApp.configure()
            }
        }
    }
}
