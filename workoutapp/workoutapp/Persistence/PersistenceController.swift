//
//  PersistenceController.swift
//  workoutapp
//
//  Created by Zach Smith on 6/12/25.
//

import CoreData
import Foundation
import os.log

struct PersistenceController {
    static let shared = PersistenceController()
    
    private static let logger = Logger(subsystem: "com.workoutapp.persistence", category: "CoreData")
    
    let container: NSPersistentContainer

    var context: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WorkoutModel")
        
        if let storeDescription = container.persistentStoreDescriptions.first {
            // Enable automatic lightweight migration
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.shouldInferMappingModelAutomatically = true
            
            if inMemory {
                storeDescription.url = URL(fileURLWithPath: "/dev/null")
            }
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Log the error for debugging and analytics
                Self.logger.error("Core Data failed to load store: \(error.localizedDescription)")
                Self.logger.error("Error details: \(error.userInfo)")
                
                // In production, you would:
                // 1. Send this error to your crash analytics service
                // 2. Show a user-friendly error message
                // 3. Potentially offer a "reset app data" option
                
                #if DEBUG
                // In development, crash to catch issues early
                fatalError("Core Data store failed to load: \(error)")
                #else
                // In production, still crash but with logging
                // You could implement graceful degradation here if needed
                fatalError("Core Data store failed to load. Please restart the app.")
                #endif
            } else {
                Self.logger.info("Core Data store loaded successfully")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
