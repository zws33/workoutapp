//
//  ScheduleEntity+CoreDataProperties.swift
//  workoutapp
//
//  Created by Zach Smith on 6/15/25.
//
//

import Foundation
import CoreData


extension ScheduleEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScheduleEntity> {
        return NSFetchRequest<ScheduleEntity>(entityName: "ScheduleEntity")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged public var workouts: NSSet?

}

// MARK: Generated accessors for workouts
extension ScheduleEntity {

    @objc(addWorkoutsObject:)
    @NSManaged public func addToWorkouts(_ value: WorkoutEntity)

    @objc(removeWorkoutsObject:)
    @NSManaged public func removeFromWorkouts(_ value: WorkoutEntity)

    @objc(addWorkouts:)
    @NSManaged public func addToWorkouts(_ values: NSSet)

    @objc(removeWorkouts:)
    @NSManaged public func removeFromWorkouts(_ values: NSSet)

}

extension ScheduleEntity : Identifiable {

}
