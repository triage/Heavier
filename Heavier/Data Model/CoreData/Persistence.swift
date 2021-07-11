//
//  Persistence.swift
//  Overload
//
//  Created by Eric Schulte on 9/22/20.
//

import CoreData
import Combine

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let exercise = Exercise(context: viewContext)
            exercise.name = "New Exercise"
            exercise.id = UUID()
            
            let lift = Lift(context: viewContext)
            lift.id = UUID()
            lift.timestamp = Date()
            lift.reps = 10
            lift.sets = 3
            lift.weight = 135
            
            exercise.lifts = NSOrderedSet(
                object: lift
            )
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer
    
    private static var defaultsKey = "defaults_loaded"
    private static var defaultsV2Key = "defaultsV2_loaded"
    private static var featureAddRelevanceKey = "feature_relevance_v1"
    
    class ExerciseJSONObject: Decodable {
        let name: String
        let relevance: Int
    }

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Overload")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may
                // be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection
                * when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                PersistenceController.performDataMigration()
            }
        })
    }
    
    @discardableResult
    private static func importDefaultExercisesIfNecessary() -> Future<Bool, Never> {
        Future { promise in
            if UserDefaults.standard.bool(forKey: PersistenceController.defaultsKey) == true {
                // already have old-style default content
                if UserDefaults.standard.bool(forKey: PersistenceController.featureAddRelevanceKey) == false {
                    // upgrade
                    DispatchQueue.global().async {
                        guard let exercises: [ExerciseJSONObject]
                                = JSONSerialization.load(fileName: "exercises-default") else {
                            return
                        }
                        PersistenceController.shared.container.performBackgroundTask { (context) in
                            exercises.forEach { json in
                                let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "name =[c] %@", json.name)
                                if let results: [Exercise] = try? context.fetch(fetchRequest) {
                                    results.forEach {
                                        $0.relevance = Int16(json.relevance)
                                    }
                                }
                            }
                            do {
                                try context.save()
                                UserDefaults.standard.set(
                                    true,
                                    forKey: PersistenceController.featureAddRelevanceKey
                                )
                                promise(.success(true))
                            } catch {
                                print("unable to save changes to relevance")
                                promise(.success(true))
                            }
                        }
                    }
                } else {
                    promise(.success(false))
                }
            } else {
                promise(.success(false))
            }
        }
    }
    
    @discardableResult
    private static func addRelevanceIfNecessary() -> Future<Bool, Never> {
        Future { promise in
            if UserDefaults.standard.bool(forKey: PersistenceController.defaultsV2Key) == false {
                // default content
                DispatchQueue.global().async {
                    PersistenceController.shared.container.performBackgroundTask { (context) in
                        guard let exercises: [ExerciseJSONObject]
                                = JSONSerialization.load(fileName: "exercises-default") else {
                            return
                        }
                        exercises.forEach { json in
                            guard let exercise
                                    = Exercise(
                                        name: json.name.capitalized,
                                        relevance: json.relevance, context: context
                                    ) else {
                                return
                            }
                            exercise.id = UUID()
                        }
                        do {
                            try context.save()
                            UserDefaults.standard.set(true, forKey: PersistenceController.defaultsV2Key)
                            promise(.success(true))
                        } catch {
                            print("unable to save default content")
                            promise(.success(true))
                        }
                    }
                }
            }
            promise(.success(false))
        }
    }
    
    private static func performDataMigration() {
        _ = importDefaultExercisesIfNecessary().sink { migrated in
            if !migrated {
                addRelevanceIfNecessary()
            }
        }
    }
}
