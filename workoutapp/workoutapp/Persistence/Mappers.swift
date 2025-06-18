//
//  Mappers.swift
//  workoutapp
//
//  Created by Zach Smith on 6/15/25.
//


import Foundation
import CoreData

extension ExerciseEntity {
    func toExercise() -> Exercise {
        return Exercise(
            id: self.identifier!,
            name: self.name ?? "",
            sets: Int(self.sets),
            reps: self.reps > 0 ? Int(self.reps) : nil,
            weight: self.weight?.isEmpty == false ? self.weight : nil,
            notes: self.notes?.isEmpty == false ? self.notes : nil
        )
    }
}

extension ExerciseGroupEntity {
    func toExerciseGroup() throws -> (String, [Exercise]) {
        guard let groupKey = self.groupKey else {
            throw CoreDataError.invalidData("Exercise group key is missing")
        }
        
        var exerciseList: [Exercise] = []
        
        // Convert ExerciseEntity to Exercise
        if let exerciseEntities = self.exercises?.allObjects as? [ExerciseEntity] {
            for exerciseEntity in exerciseEntities {
                let exercise = exerciseEntity.toExercise()
                exerciseList.append(exercise)
            }
        }
        
        return (groupKey, exerciseList)
    }
}

extension ScheduleEntity {
    func toSchedule() throws -> Schedule {
        guard let name = self.name else {
            throw CoreDataError.invalidData("Schedule name is missing")
        }
        
        var workouts: [Workout] = []
        
        // Convert WorkoutEntity to Workout
        if let workoutEntities = self.workouts?.allObjects as? [WorkoutEntity] {
            for workoutEntity in workoutEntities.sorted(by:{ $0.day! < $1.day! }) {
                let workout = try workoutEntity.toWorkout()
                workouts.append(workout)
            }
        }
        
        return Schedule(id: self.identifier!, name: name, workouts: workouts)
    }
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
        
        return Workout(id: self.identifier!, day: day, exercises: exercises)
    }
}
