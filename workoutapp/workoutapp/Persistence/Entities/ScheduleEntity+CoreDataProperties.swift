//
//  ScheduleEntity+CoreDataProperties.swift
//  workoutapp
//
//  Created by Zach Smith on 6/13/25.
//
//

import Foundation
import CoreData


extension ScheduleEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScheduleEntity> {
        return NSFetchRequest<ScheduleEntity>(entityName: "ScheduleEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: String?
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

extension ScheduleEntity {
    func toSchedule() throws -> Schedule {
        guard let name = self.name else {
            throw CoreDataError.invalidData("Schedule name is missing")
        }
        
        var workouts: [Workout] = []
        
        // Convert WorkoutEntity to Workout
        if let workoutEntities = self.workouts?.allObjects as? [WorkoutEntity] {
            for workoutEntity in workoutEntities {
                let workout = try workoutEntity.toWorkout()
                workouts.append(workout)
            }
        }
        
        return Schedule(name: name, workouts: workouts)
    }
}


