//
//  Models.swift
//  workoutapp
//
//  Created by Zach Smith on 4/15/25.
//

import Foundation

struct Schedule: Codable, Equatable {
    
    let name: String
    let workouts: [Workout]
    init(name: String, workouts: [Workout]) {
        self.name = name
        self.workouts = workouts
    }
}

struct Workout: Codable, Equatable {
    let day: String
    let exercises: [String: [Exercise]]
    init(day: String, exercises: [String : [Exercise]]) {
        self.day = day
        self.exercises = exercises
    }
}

struct Exercise: Codable, Equatable {
    
    let name: String
    let sets: Int
    let reps: Int
    let weight: String
    let notes: String
    init(name: String, sets: Int, reps: Int, weight: String, notes: String, id: String? = nil) {
        
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.notes = notes
    }
}
