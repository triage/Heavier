//
//  OverloadApp.swift
//  Overload
//
//  Created by Eric Schulte on 9/22/20.
//

import SwiftUI
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
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        Task {
                            do {
                                let response = try await HeavierApp.functions.httpsCallable("exercise_resolve_name").call(["query": "Dumbbell bench press"])
                                let name = response.data as? String
                                print("resolved:\(name)")
                            } catch (let error) {
                                print("error:\(error)")
                            }
                        }
                    }
                }
            }
        }
    }
