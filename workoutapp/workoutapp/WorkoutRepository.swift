//
//  WorkoutRepository.swift
//  workoutapp
//
//  Created by Zach Smith on 4/15/25.
//

import Foundation
import GoogleSignIn
import CoreData
import Combine
import os.log


protocol WorkoutRepository {
    func getSchedule(for week: String) async throws -> Schedule
    func fetchWeeks() async throws -> [String]
}

class WorkoutRepositoryImpl: WorkoutRepository {
    private let session: URLSession
    private let isProd: Bool
    private let authManager: AuthManager

    
    init(session: URLSession = .shared,
         isProd: Bool = true,
         authManager: AuthManager
    ) {
        self.session = session
        self.isProd = isProd
        self.authManager = authManager
    }
    
    private var baseURL: String {
        isProd ? "https://zwsmith.me" : "http://localhost:3000"
    }
    
    private func workoutsURL(for week: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)/api/workouts/\(week)") else {
            throw NetworkError.invalidURL("Failed to create URL for week: \(week)")
        }
        return url
    }
    
    func getSchedule(for week: String) async throws -> Schedule {
        let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
        
        let localSchedule: Schedule? = try await backgroundContext.perform {
            let fetchRequest: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", week)
            fetchRequest.fetchLimit = 1
            
            let result = try backgroundContext.fetch(fetchRequest)
            
            if let scheduleEntity = result.first {
                return try scheduleEntity.toSchedule()
            }
            return nil
        }
        
        if let schedule = localSchedule {
            AppLogger.info("Returning local schedule for week: \(week)", category: .coreData)
            return schedule
        } else {
            AppLogger.info("Fetching schedule from remote")
            let remoteSchedule = try await fetchSchedule(for: week)
            AppLogger.info("Saving schedule to local")
            do {
                try await saveSchedule(remoteSchedule)
            } catch {
                AppLogger.error(error.localizedDescription, category: .coreData)
                throw error
            }
            
            AppLogger.info("Returning remote schedule for week: \(week)", category: .networking)
            return remoteSchedule
        }
    }
    
    private func fetchSchedule(for week: String) async throws -> Schedule {
        var request = URLRequest(url: try workoutsURL(for: week))
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        let idToken = try await authManager.getIDToken()
        request.addValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Schedule.self, from: data)
        } catch {
            AppLogger.error("Failed to decode Schedule JSON for week: \(week)", error: error, category: .networking)
            throw NetworkError.decodingFailed(error)
        }
    }
    
    func fetchWeeks() async throws -> [String] {
        guard let url = URL(string: "\(baseURL)/api/sheets") else {
            throw NetworkError.invalidURL("Failed to create URL for sheets endpoint")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let idToken = try await authManager.getIDToken()
        request.addValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            AppLogger.error("Network request failed for fetchWeeks", error: error, category: .networking)
            throw NetworkError.transportError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        do {
            let weeks = try JSONDecoder().decode([String].self, from: data)
            return weeks
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
    
    private func saveSchedule(_ schedule: Schedule) async throws {
        // Create a new background context for this operation
        let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
        
        try await backgroundContext.perform {
            let scheduleEntity = ScheduleEntity(context: backgroundContext)
            scheduleEntity.identifier = schedule.id
            scheduleEntity.name = schedule.name

            for workout in schedule.workouts {
                let workoutEntity = WorkoutEntity(context: backgroundContext)
                workoutEntity.identifier = workout.id
                workoutEntity.day = workout.day
                workoutEntity.schedule = scheduleEntity

                for (groupKey, exercises) in workout.exercises {
                    let groupEntity = ExerciseGroupEntity(context: backgroundContext)
                    groupEntity.groupKey = groupKey
                    groupEntity.workout = workoutEntity

                    for exercise in exercises {
                        let exerciseEntity = ExerciseEntity(context: backgroundContext)
                        exerciseEntity.identifier = exercise.id
                        exerciseEntity.name = exercise.name
                        exerciseEntity.sets = Int64(exercise.sets)
                        exerciseEntity.reps = Int64(exercise.reps)
                        exerciseEntity.weight = exercise.weight
                        exerciseEntity.notes = exercise.notes
                        exerciseEntity.exerciseGroup = groupEntity
                    }
                }
            }
            
            try backgroundContext.save()
        }
    }
}

struct FakeWorkoutRepository: WorkoutRepository {
    
    func fetchWeeks() async throws -> [String] {
        return ["Week 1", "Week 2", "Week 3"]
    }
    
    func getSchedule(for week: String) async throws -> Schedule {
        return Schedule(
            name: week,
            workouts: [
                Workout(
                    day: "Monday",
                    exercises: [
                        "Primary": [
                            Exercise(name: "Push-ups", sets: 3, reps: 15, weight: "Bodyweight", notes: "Keep elbows close to body"),
                            Exercise(name: "Bench Press", sets: 4, reps: 8, weight: "135 lbs", notes: "")
                        ],
                        "Secondary": [
                            Exercise(name: "Incline Dumbbell Press", sets: 3, reps: 12, weight: "40 lbs", notes: "Slow controlled movement")
                        ]
                    ]
                ),
                Workout(
                    day: "Tuesday",
                    exercises: [
                        "Cardio": [
                            Exercise(name: "Treadmill Run", sets: 1, reps: 0, weight: "", notes: "20 minutes at moderate pace")
                        ],
                        "Core": [
                            Exercise(name: "Plank", sets: 3, reps: 0, weight: "", notes: "Hold for 60 seconds"),
                            Exercise(name: "Russian Twists", sets: 3, reps: 20, weight: "15 lbs", notes: "")
                        ]
                    ]
                ),
                Workout(
                    day: "Wednesday",
                    exercises: [
                        "Primary": [
                            Exercise(name: "Squats", sets: 4, reps: 12, weight: "185 lbs", notes: "Focus on form"),
                            Exercise(name: "Deadlifts", sets: 3, reps: 8, weight: "225 lbs", notes: "Keep back straight")
                        ]
                    ]
                )
            ]
        )
    }
}
