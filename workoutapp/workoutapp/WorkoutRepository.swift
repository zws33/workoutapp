//
//  WorkoutRepository.swift
//  workoutapp
//
//  Created by Zach Smith on 4/15/25.
//

import Foundation
import GoogleSignIn

protocol WorkoutRepository {
    func fetchWorkouts(for week: String) async throws -> WorkoutGroup
    func fetchWeeks() async throws -> [String]
}

class WorkoutRepositoryImpl: WorkoutRepository {
    private let session: URLSession
    private let isProd: Bool
    private let authManager: AuthManager
    
    init(session: URLSession = .shared, isProd: Bool = true, authManager: AuthManager) {
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
    
    func fetchWorkouts(for week: String) async throws -> WorkoutGroup {
        var request = URLRequest(url: workoutsURL(for: week))
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        guard let idToken = authManager.token else {
            throw AuthError.missingToken
        }
        request.addValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        print("ok")
        
        do {
            let workout = try createWorkoutGroup(from: data)
            return workout
        } catch {
            print("error")
            throw NetworkError.decodingFailed(error)
        }
    }
    
    func fetchWeeks() async throws -> [String] {
        let url = URL(string: "\(baseURL)/api/sheets")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let idToken = authManager.token else {
            throw AuthError.missingToken
        }
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
}

func createWorkoutGroup(from data: Data) throws -> WorkoutGroup {
    let decoder = JSONDecoder()
    return try decoder.decode(WorkoutGroup.self, from: data)
}

struct FakeWorkoutRepository: WorkoutRepository {
    
    func fetchWeeks() async throws -> [String] {
        return ["Week 1"]
    }
    
    func fetchWorkouts(for week: String) async throws -> WorkoutGroup {
        WorkoutGroup(
            name: "Week 1",
            workouts: [
                "1" : WorkoutDay(
                    day: "1",
                    exercises : [
                        "primary" : [Exercise(name: "pushups", sets: 1, reps: 10, weight: 35, notes: "")]
                    ]
                )
            ]
        )
    }
}
