//
//  WorkoutEntity+CoreDataProperties.swift
//  workoutapp
//
//  Created by Zach Smith on 8/1/25.
//
//

import Foundation
import CoreData


extension WorkoutEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutEntity> {
        return NSFetchRequest<WorkoutEntity>(entityName: "WorkoutEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var identifier: String?
    @NSManaged public var exerciseGroups: NSSet?
    @NSManaged public var schedule: ScheduleEntity?

}

// MARK: Generated accessors for exerciseGroups
extension WorkoutEntity {

    @objc(addExerciseGroupsObject:)
    @NSManaged public func addToExerciseGroups(_ value: ExerciseGroupEntity)

    @objc(removeExerciseGroupsObject:)
    @NSManaged public func removeFromExerciseGroups(_ value: ExerciseGroupEntity)

    @objc(addExerciseGroups:)
    @NSManaged public func addToExerciseGroups(_ values: NSSet)

    @objc(removeExerciseGroups:)
    @NSManaged public func removeFromExerciseGroups(_ values: NSSet)

}

extension WorkoutEntity : Identifiable {

}
