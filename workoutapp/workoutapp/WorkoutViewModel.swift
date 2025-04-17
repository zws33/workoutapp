//
//  WorkoutViewModel.swift
//  workoutapp
//
//  Created by Zach Smith on 4/15/25.
//


import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST_Sheets

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var state: WorkoutViewState = .Loading
    
    private let repository: WorkoutRepository

    init(repository: WorkoutRepository) {
        self.repository = repository
    }
    
    func getData() async {
        state = .Loading
        print("current state: \(state)")
        do {
            let workouts = try await repository.fetchWorkouts(for: "Week 1")
            state = .Data(workouts)
        } catch {
            state = .Error(error.localizedDescription)
        }
    }
}

enum WorkoutViewState: Equatable {
    case Loading
    case Error(String)
    case Data([String: [Exercise]])
}
