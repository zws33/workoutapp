//
//  ExerciseGroupEntity+CoreDataProperties.swift
//  workoutapp
//
//  Created by Zach Smith on 6/13/25.
//
//

import Foundation
import CoreData


extension ExerciseGroupEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseGroupEntity> {
        return NSFetchRequest<ExerciseGroupEntity>(entityName: "ExerciseGroupEntity")
    }

    @NSManaged public var groupKey: String?
    @NSManaged public var workout: WorkoutEntity?
    @NSManaged public var exercises: NSSet?

}

// MARK: Generated accessors for exercises
extension ExerciseGroupEntity {

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: ExerciseEntity)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: ExerciseEntity)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSSet)

}

extension ExerciseGroupEntity : Identifiable {

}
