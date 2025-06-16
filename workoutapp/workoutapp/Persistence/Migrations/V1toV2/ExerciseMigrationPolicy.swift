//
//  ExerciseMigrationPolicy.swift
//  workoutapp
//
//  Created by Claude on 6/16/25.
//

import CoreData
import Foundation

class ExerciseMigrationPolicy: NSEntityMigrationPolicy {
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, 
                                           in mapping: NSEntityMapping, 
                                           manager: NSMigrationManager) throws {
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
        
        // Get the destination instance that was just created
        guard let destinationInstance = manager.destinationInstances(
            forEntityMappingName: mapping.name,
            sourceInstances: [sInstance]
        ).first else {
            throw NSError(domain: "MigrationError", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create destination instance"
            ])
        }
        
        // Generate UUID for identifier if it doesn't exist
        if destinationInstance.value(forKey: "identifier") == nil {
            destinationInstance.setValue(UUID().uuidString, forKey: "identifier")
        }
    }
}

class ScheduleMigrationPolicy: NSEntityMigrationPolicy {
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, 
                                           in mapping: NSEntityMapping, 
                                           manager: NSMigrationManager) throws {
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
        
        guard let destinationInstance = manager.destinationInstances(
            forEntityMappingName: mapping.name,
            sourceInstances: [sInstance]
        ).first else {
            throw NSError(domain: "MigrationError", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create destination instance"
            ])
        }
        
        if destinationInstance.value(forKey: "identifier") == nil {
            destinationInstance.setValue(UUID().uuidString, forKey: "identifier")
        }
    }
}

class WorkoutMigrationPolicy: NSEntityMigrationPolicy {
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, 
                                           in mapping: NSEntityMapping, 
                                           manager: NSMigrationManager) throws {
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
        
        guard let destinationInstance = manager.destinationInstances(
            forEntityMappingName: mapping.name,
            sourceInstances: [sInstance]
        ).first else {
            throw NSError(domain: "MigrationError", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create destination instance"
            ])
        }
        
        if destinationInstance.value(forKey: "identifier") == nil {
            destinationInstance.setValue(UUID().uuidString, forKey: "identifier")
        }
    }
}