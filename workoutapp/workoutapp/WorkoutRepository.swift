//
//  WorkoutRepository.swift
//  workoutapp
//
//  Created by Zach Smith on 4/15/25.
//

import Combine
import CoreData
import Foundation
import GoogleSignIn
import os.log

// MARK: - WorkoutRepository Protocol

protocol WorkoutRepository {
    func getSchedule(for week: String) async throws -> Schedule
    func getSchedules() async throws -> [Schedule]
    func syncSchedulesWithRemote() async throws
}

// MARK: - WorkoutRepositoryImpl

class WorkoutRepositoryImpl: WorkoutRepository {

    // MARK: - Properties

    private let session: URLSession
    private let isProd: Bool
    private let authManager: AuthManager
    private let refreshInterval: TimeInterval = 259_200

    private var baseURL: String {
        isProd ? "https://zwsmith.me" : "http://localhost:3000"
    }

    // MARK: - Initialization

    init(
        session: URLSession = .shared,
        isProd: Bool = true,
        authManager: AuthManager
    ) {
        self.session = session
        self.isProd = isProd
        self.authManager = authManager
    }

    // MARK: - Public Methods

    func getSchedule(for week: String) async throws -> Schedule {
        let backgroundContext = PersistenceController.shared.container
            .newBackgroundContext()

        let localSchedule: Schedule? = try await backgroundContext.perform {
            let fetchRequest: NSFetchRequest<ScheduleEntity> =
                ScheduleEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", week)
            fetchRequest.fetchLimit = 1

            let result = try backgroundContext.fetch(fetchRequest)

            if let scheduleEntity = result.first {
                return try scheduleEntity.toSchedule()
            }
            return nil
        }

        if let schedule = localSchedule {
            AppLogger.info(
                "Returning local schedule for week: \(week)",
                category: .coreData)
            return schedule
        } else {
            AppLogger.info("Fetching schedule from remote")
            let remoteSchedule = try await fetchSchedule(for: week)
            AppLogger.info("Saving schedule to local")
            do {
                try await saveSchedule(remoteSchedule)
            } catch {
                AppLogger.error(
                    "Failed to save schedule", error: error, category: .coreData
                )
                throw error
            }

            AppLogger.info(
                "Returning remote schedule for: \(week)", category: .networking)
            return remoteSchedule
        }
    }

    func getSchedules() async throws -> [Schedule] {

        if shouldRefreshData() {
            do {
                AppLogger.info(
                    "Local data is stale. Syncing schedules...",
                    category: .general)
                try await syncSchedulesWithRemote()
            } catch {
                AppLogger.error(
                    "Failed to sync schedules", error: error, category: .general
                )
            }

        }

        let schedules = try await loadLocalSchedules()
        if schedules.isEmpty {
            AppLogger.warning(
                "No schedules found locally. Syncing schedules...",
                category: .general)
            try await syncSchedulesWithRemote()
            return try await loadLocalSchedules()
        }
        return schedules
    }

    func syncSchedulesWithRemote() async throws {
        let schedules = try await fetchSchedules()

        try await clearAllSchedules()

        var synced = 0
        for schedule in schedules {
            do {
                try await saveSchedule(schedule)
                synced += 1
            } catch {
                AppLogger.error(
                    "Failed to save schedule - id: \(schedule.id) name: \(schedule.name)",
                    error: error, category: .coreData)
                throw error
            }
        }
        setRefreshTimestamp()
        AppLogger.info("\(synced)/\(schedules.count) schedules saved")
    }

    // MARK: - Private Methods

    private func workoutsURL(for week: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)/api/workouts/\(week)") else {
            throw NetworkError.invalidURL(
                "Failed to create URL for week: \(week)")
        }
        return url
    }

    private func fetchSchedule(for week: String) async throws -> Schedule {
        var request = URLRequest(url: try workoutsURL(for: week))
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let idToken = try await authManager.getIDToken()
        request.addValue(
            "Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw NetworkError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Schedule.self, from: data)
        } catch {
            AppLogger.error(
                "Failed to decode data", error: error, category: .networking)
            throw NetworkError.decodingFailed(error)
        }
    }

    private func fetchSchedules() async throws -> [Schedule] {
        let requestId = UUID().uuidString.prefix(8).uppercased()
        let startTime = Date()
        let urlString = "\(baseURL)/api/schedules"
        
        AppLogger.httpRequest(.requestStart, requestId: String(requestId), url: urlString)
        
        guard let url = URL(string: urlString) else {
            AppLogger.httpRequest(.requestFailed, requestId: String(requestId), url: urlString, error: NetworkError.invalidURL("Failed to create URL"))
            throw NetworkError.invalidURL("Failed to create URL for sheets endpoint")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let idToken = try await authManager.getIDToken()
            AppLogger.httpRequest(.authTokenRetrieved, requestId: String(requestId))
            request.addValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        } catch {
            AppLogger.httpRequest(.requestFailed, requestId: String(requestId), error: error)
            throw error
        }

        AppLogger.httpRequest(.networkCallStarted, requestId: String(requestId), url: urlString)
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
            AppLogger.httpRequest(.responseReceived, requestId: String(requestId), url: urlString)
        } catch {
            AppLogger.httpRequest(.requestFailed, requestId: String(requestId), url: urlString, error: error)
            throw NetworkError.transportError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            AppLogger.httpRequest(.requestFailed, requestId: String(requestId), error: NetworkError.invalidResponse)
            throw NetworkError.invalidResponse
        }
        
        AppLogger.httpRequest(.responseReceived, requestId: String(requestId), url: urlString, statusCode: httpResponse.statusCode)
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let statusError = NetworkError.httpError(httpResponse.statusCode)
            AppLogger.httpRequest(.requestFailed, requestId: String(requestId), statusCode: httpResponse.statusCode, error: statusError)
            throw statusError
        }
        
        AppLogger.httpRequest(.responseValidated, requestId: String(requestId), statusCode: httpResponse.statusCode)
        AppLogger.httpRequest(.decodingStarted, requestId: String(requestId))

        do {
            let response = try JSONDecoder().decode(SchedulesResponse.self, from: data)
            AppLogger.httpRequest(.decodingCompleted, requestId: String(requestId))
            
            let duration = Date().timeIntervalSince(startTime)
            AppLogger.httpRequest(.requestCompleted, requestId: String(requestId), duration: duration)
            AppLogger.info("\(response.data.count) schedules fetched", category: .networking)
            
            return response.data
        } catch {
            AppLogger.httpRequest(.requestFailed, requestId: String(requestId), error: error)
            throw NetworkError.decodingFailed(error)
        }
    }

    // MARK: - Core Data Methods

    private func loadLocalSchedules() async throws -> [Schedule] {
        let backgroundContext = PersistenceController.shared.container
            .newBackgroundContext()

        return try await backgroundContext.perform {
            let fetchRequest = ScheduleEntity.fetchRequest()

            do {
                let results = try backgroundContext.fetch(fetchRequest)

                // Handle empty results case
                guard !results.isEmpty else {
                    AppLogger.info(
                        "No schedules found in Core Data", category: .coreData)
                    return []
                }

                var schedules: [Schedule] = []

                for scheduleEntity in results {
                    do {
                        let schedule = try scheduleEntity.toSchedule()
                        schedules.append(schedule)
                    } catch {
                        AppLogger.error(
                            "Failed to convert ScheduleEntity to Schedule",
                            error: error, category: .coreData)
                        throw error
                    }
                }

                AppLogger.info(
                    "Successfully loaded \(schedules.count) schedules from Core Data",
                    category: .coreData)
                return schedules

            } catch {
                AppLogger.error(
                    "Core Data fetch failed for schedules", error: error,
                    category: .coreData)
                throw error
            }
        }
    }

    private func saveSchedule(_ schedule: Schedule) async throws {
        // Create a new background context for this operation
        let backgroundContext = PersistenceController.shared.container
            .newBackgroundContext()

        try await backgroundContext.perform {
            let scheduleEntity = ScheduleEntity(context: backgroundContext)
            scheduleEntity.identifier = schedule.id
            scheduleEntity.name = schedule.name

            for workout in schedule.workouts {
                let workoutEntity = WorkoutEntity(context: backgroundContext)
                workoutEntity.identifier = workout.id
                workoutEntity.name = workout.name
                workoutEntity.schedule = scheduleEntity

                for (groupKey, exercises) in workout.exercises {
                    let groupEntity = ExerciseGroupEntity(
                        context: backgroundContext)
                    groupEntity.groupKey = groupKey
                    groupEntity.workout = workoutEntity

                    for exercise in exercises {
                        let exerciseEntity = ExerciseEntity(
                            context: backgroundContext)
                        exerciseEntity.identifier = exercise.id
                        exerciseEntity.name = exercise.name
                        exerciseEntity.sets = Int64(exercise.sets)
                        exerciseEntity.reps = Int64(exercise.reps ?? -1)
                        exerciseEntity.weight = exercise.weight
                        exerciseEntity.notes = exercise.notes
                        exerciseEntity.exerciseGroup = groupEntity
                    }
                }
            }

            try backgroundContext.save()
        }
    }

    private func clearAllSchedules() async throws {
        let backgroundContext = PersistenceController.shared.container
            .newBackgroundContext()

        try await backgroundContext.perform {
            let fetchRequest = ScheduleEntity.fetchRequest()

            do {
                let schedules = try backgroundContext.fetch(fetchRequest)
                for schedule in schedules {
                    backgroundContext.delete(schedule)
                }

                try backgroundContext.save()
                AppLogger.info(
                    "Cleared \(schedules.count) existing schedules from Core Data",
                    category: .coreData)
            } catch {
                AppLogger.error(
                    "Failed to clear existing schedules", error: error,
                    category: .coreData)
                throw error
            }
        }
    }

    // MARK: - Helper Methods

    private func setRefreshTimestamp() {
        UserDefaults.standard.set(Date(), forKey: "lastDataRefresh")
    }

    private func shouldRefreshData() -> Bool {
        let lastRefresh =
            UserDefaults.standard.object(forKey: "lastDataRefresh") as? Date
        return lastRefresh.map {
            Date().timeIntervalSince($0) > refreshInterval
        } ?? true
    }
}

// MARK: - FakeWorkoutRepository

struct FakeWorkoutRepository: WorkoutRepository {
    
    // MARK: - Public Methods
    
    func getSchedule(for week: String) async throws -> Schedule {
        return createFakeSchedule(for: week)
    }

    func getSchedules() async throws -> [Schedule] {
        return [createFakeSchedule(for: "Week 1")]
    }

    func syncSchedulesWithRemote() async throws {
        // No-op
    }
    
    // MARK: - Private Methods

    private func createFakeSchedule(for week: String) -> Schedule {
        return Schedule(
            id: UUID().uuidString,
            name: week,
            workouts: [
                Workout(
                    id: UUID().uuidString,
                    name: "Monday",
                    exercises: [
                        "Primary": [
                            Exercise(
                                id: UUID().uuidString,
                                name: "Push-ups",
                                sets: 3,
                                reps: 15,
                                weight: "Bodyweight",
                                notes: "Keep elbows close to body"
                            ),
                            Exercise(
                                id: UUID().uuidString,
                                name: "Bench Press",
                                sets: 4,
                                reps: 8,
                                weight: "135 lbs",
                                notes: ""
                            ),
                        ],
                        "Secondary": [
                            Exercise(
                                id: UUID().uuidString,
                                name: "Incline Dumbbell Press",
                                sets: 3,
                                reps: 12,
                                weight: "40 lbs",
                                notes: "Slow controlled movement"
                            )
                        ],
                    ]
                ),
                Workout(
                    id: UUID().uuidString,
                    name: "Tuesday",
                    exercises: [
                        "Cardio": [
                            Exercise(
                                id: UUID().uuidString,
                                name: "Treadmill Run",
                                sets: 1,
                                reps: 0,
                                weight: "",
                                notes: "20 minutes at moderate pace"
                            )
                        ],
                        "Core": [
                            Exercise(
                                id: UUID().uuidString,
                                name: "Plank",
                                sets: 3,
                                reps: 0,
                                weight: "",
                                notes: "Hold for 60 seconds"
                            ),
                            Exercise(
                                id: UUID().uuidString,
                                name: "Russian Twists",
                                sets: 3,
                                reps: 20,
                                weight: "15 lbs",
                                notes: ""
                            ),
                        ],
                    ]
                ),
                Workout(
                    id: UUID().uuidString,
                    name: "Wednesday",
                    exercises: [
                        "Primary": [
                            Exercise(
                                id: UUID().uuidString,
                                name: "Squats",
                                sets: 4,
                                reps: 12,
                                weight: "185 lbs",
                                notes: "Focus on form"
                            ),
                            Exercise(
                                id: UUID().uuidString,
                                name: "Deadlifts",
                                sets: 3,
                                reps: 8,
                                weight: "225 lbs",
                                notes: "Keep back straight"
                            ),
                        ]
                    ]
                ),
            ]
        )
    }
}
