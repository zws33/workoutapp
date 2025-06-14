//
//  PersistenceController.swift
//  workoutapp
//
//  Created by Zach Smith on 6/12/25.
//

import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var context: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WorkoutModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(
                fileURLWithPath: "/dev/null"
            )
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
