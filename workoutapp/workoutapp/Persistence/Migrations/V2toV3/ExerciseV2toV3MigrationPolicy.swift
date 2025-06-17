import CoreData
import Foundation

class ExerciseV2toV3MigrationPolicy: NSEntityMigrationPolicy {
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, 
                                           in mapping: NSEntityMapping, 
                                           manager: NSMigrationManager) throws {
        
        let destinationInstance = NSEntityDescription.insertNewObject(
            forEntityName: mapping.destinationEntityName!,
            into: manager.destinationContext
        )
        
        // Copy non-optional attributes directly
        destinationInstance.setValue(sInstance.value(forKey: "id"), forKey: "id")
        destinationInstance.setValue(sInstance.value(forKey: "name"), forKey: "name")
        destinationInstance.setValue(sInstance.value(forKey: "sets"), forKey: "sets")
        
        // Handle reps: Convert 0 or negative values to nil
        if let reps = sInstance.value(forKey: "reps") as? Int64, reps > 0 {
            destinationInstance.setValue(reps, forKey: "reps")
        } else {
            destinationInstance.setValue(nil, forKey: "reps")
        }
        
        // Handle weight: Convert empty strings to nil
        if let weight = sInstance.value(forKey: "weight") as? String, !weight.isEmpty {
            destinationInstance.setValue(weight, forKey: "weight")
        } else {
            destinationInstance.setValue(nil, forKey: "weight")
        }
        
        // Handle notes: Convert empty strings to nil
        if let notes = sInstance.value(forKey: "notes") as? String, !notes.isEmpty {
            destinationInstance.setValue(notes, forKey: "notes")
        } else {
            destinationInstance.setValue(nil, forKey: "notes")
        }
        
        manager.associate(sourceInstance: sInstance, withDestinationInstance: destinationInstance, for: mapping)
    }
}