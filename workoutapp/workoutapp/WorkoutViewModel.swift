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
    private let selectedWeek: String

    init(repository: WorkoutRepository, selectedWeek: String) {
        self.repository = repository
        self.selectedWeek = selectedWeek
    }
    
    func getWorkouts() async {
        state = .Loading
        do {
            let workouts = try await repository.fetchWorkouts(for: selectedWeek)
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
