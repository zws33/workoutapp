//
//  WorkoutEntity+CoreDataProperties.swift
//  workoutapp
//
//  Created by Zach Smith on 6/13/25.
//
//

import Foundation
import CoreData


extension WorkoutEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutEntity> {
        return NSFetchRequest<WorkoutEntity>(entityName: "WorkoutEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var day: String?
    @NSManaged public var schedule: ScheduleEntity?
    @NSManaged public var exerciseGroups: NSSet?

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

extension WorkoutEntity {
    func toWorkout() throws -> Workout {
        guard let day = self.day else {
            throw CoreDataError.invalidData("Workout day is missing")
        }
        
        var exercises: [String: [Exercise]] = [:]
        
        // Convert ExerciseGroupEntity to grouped exercises
        if let groupEntities = self.exerciseGroups?.allObjects as? [ExerciseGroupEntity] {
            for groupEntity in groupEntities {
                let (groupKey, exerciseList) = try groupEntity.toExerciseGroup()
                exercises[groupKey] = exerciseList
            }
        }
        
        return Workout(day: day, exercises: exercises)
    }
}

