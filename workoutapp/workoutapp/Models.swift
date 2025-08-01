//
//  Models.swift
//  workoutapp
//
//  Created by Zach Smith on 4/15/25.
//

import Foundation

struct SchedulesResponse: Codable {
    let success: Bool
    let data: [Schedule]
    let count: Int
}

struct Schedule: Codable, Equatable {
    let id: String
    let name: String
    let workouts: [Workout]
    init(id: String, name: String, workouts: [Workout]) {
        self.id = id
        self.name = name
        self.workouts = workouts
    }
}

struct Workout: Codable, Equatable {
    let id: String
    let name: String
    let exercises: [String: [Exercise]]
    init(
        id: String,
        name: String,
        exercises: [String : [Exercise]]
    ) {
        self.id = id
        self.name = name
        self.exercises = exercises
    }
}

struct Exercise: Codable, Equatable {
    let id: String
    let name: String
    let sets: Int
    let reps: Int?
    let weight: String?
    let notes: String?
    init(
        id: String,
        name: String,
        sets: Int,
        reps: Int?,
        weight: String?,
        notes: String?
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.notes = notes
    }
}
