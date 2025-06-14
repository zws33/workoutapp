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
    
    private func workoutsURL(for week: String) -> URL {
        URL(string: "\(baseURL)/api/workouts/\(week)")!
    }
    
    func getSchedule(for week: String) async throws -> Schedule {
        let fetchRequest: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", week)
        fetchRequest.fetchLimit = 1
        
        let result = try PersistenceController.shared.context.fetch(fetchRequest)
        
        if let scheduleEntity = result.first {
            let localSchedule = try scheduleEntity.toSchedule()
            print("returning local schedule")
            return localSchedule
        } else {
            let remoteSchedule = try await fetchSchedule(for: week)
            try await saveSchedule(remoteSchedule)
            print("returning remote schedule")
            return remoteSchedule
        }
    }
    
    private func fetchSchedule(for week: String) async throws -> Schedule {
        var request = URLRequest(url: workoutsURL(for: week))
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
            print("error decoding JSON:", error)
            throw NetworkError.decodingFailed(error)
        }
    }
    
    func fetchWeeks() async throws -> [String] {
        let url = URL(string: "\(baseURL)/api/sheets")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let idToken = try await authManager.getIDToken()
        request.addValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("Network request failed:", error)
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
            scheduleEntity.id = UUID().uuidString
            scheduleEntity.name = schedule.name

            for workout in schedule.workouts {
                let workoutEntity = WorkoutEntity(context: backgroundContext)
                workoutEntity.id = UUID().uuidString
                workoutEntity.day = workout.day
                workoutEntity.schedule = scheduleEntity

                for (groupKey, exercises) in workout.exercises {
                    let groupEntity = ExerciseGroupEntity(context: backgroundContext)
                    groupEntity.groupKey = groupKey
                    groupEntity.workout = workoutEntity

                    for exercise in exercises {
                        let exerciseEntity = ExerciseEntity(context: backgroundContext)
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
        return ["Week 1"]
    }
    
    func getSchedule(for week: String) async throws -> Schedule {
        Schedule(
            name: "Week 1",
            workouts: [
                 Workout(
                    day: "1",
                    exercises : [
                        "primary" : [Exercise(
                            name: "pushups",
                            sets: 1,
                            reps: 10,
                            weight: "35",
                            notes: ""
                        )]
                    ]
                )
            ]
        )
    }
}
