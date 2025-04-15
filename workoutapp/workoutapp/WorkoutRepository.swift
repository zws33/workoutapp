//
//  WorkoutRepository.swift
//  workoutapp
//
//  Created by Zach Smith on 4/15/25.
//

import Foundation
import GoogleSignIn

protocol WorkoutRepository {
    func fetchWorkouts(for week: String) async throws -> [String: [Exercise]]
}

class WorkoutRepositoryImpl: WorkoutRepository {
    private let session: URLSession
    private let isProd: Bool
    
    init(session: URLSession = .shared, isProd: Bool = true) {
        self.session = session
        self.isProd = isProd
    }
    
    private var baseURL: String {
        isProd ? "https://zwsmith.me" : "http://localhost:3000"
    }
    
    private func workoutsURL(for week: String) -> URL {
        URL(string: "\(baseURL)/api/sheets/\(week)")!
    }
    
    func fetchWorkouts(for week: String) async throws -> [String: [Exercise]] {
        var request = URLRequest(url: workoutsURL(for: week))
        request.httpMethod = "GET"
        
        guard let idToken = GIDSignIn.sharedInstance.currentUser?.idToken else {
            throw AuthError.missingToken
        }
        request.addValue("Bearer \(idToken.tokenString)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode([String: [Exercise]].self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}

struct FakeWorkoutRepository: WorkoutRepository {
    func fetchWorkouts(for week: String) async throws -> [String: [Exercise]] {
        [
            "Day 1": [
                Exercise(day: "Day 1", group: "Push", name: "Bench Press", sets: "3", reps: "10", weight: "135", notes: "Control focus")
            ],
            "Day 2": [
                Exercise(day: "Day 2", group: "Pull", name: "Deadlift", sets: "5", reps: "5", weight: "225", notes: "Flat back")
            ]
        ]
    }
}
