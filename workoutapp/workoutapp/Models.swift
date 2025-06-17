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
    init(name: String, workouts: [Workout], id: String = UUID().uuidString) {
        self.id = id
        self.name = name
        self.workouts = workouts
    }
}

struct Workout: Codable, Equatable {
    let id: String
    let day: String
    let exercises: [String: [Exercise]]
    init(
        day: String,
        exercises: [String : [Exercise]],
        id: String = UUID().uuidString
    ) {
        self.id = id
        self.day = day
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
        name: String,
        sets: Int,
        reps: Int?,
        weight: String?,
        notes: String?,
        id: String = UUID().uuidString
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.notes = notes
    }
}
