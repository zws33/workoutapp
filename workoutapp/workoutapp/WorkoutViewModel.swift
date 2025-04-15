//
//  WorkoutViewModel.swift
//  workoutapp
//
//  Created by Zach Smith on 4/15/25.
//


import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST_Sheets

class WorkoutViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var workouts: [String: [Exercise]] = [:]
    
    private let repository: WorkoutRepository

    init(repository: WorkoutRepository) {
        self.repository = repository
    }
    
    @MainActor
    func getData() async {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                workouts = try await repository.fetchWorkouts(for: "Week 1")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
}
