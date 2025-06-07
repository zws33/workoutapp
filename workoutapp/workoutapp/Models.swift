//
//  Models.swift
//  workoutapp
//
//  Created by Zach Smith on 4/15/25.
//

import Foundation

struct Schedule: Codable, Equatable {
    let name: String
    let workouts: [String: WorkoutDay]
}

struct WorkoutDay: Codable, Equatable {
    let day: String
    let exercises: [String: [Exercise]]
}

struct Exercise: Codable, Equatable {
    let name: String
    let sets: Int
    let reps: Int
    let weight: String
    let notes: String
}
