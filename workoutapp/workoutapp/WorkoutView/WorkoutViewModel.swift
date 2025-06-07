//
//  WorkoutViewModel.swift
//  workoutapp
//
//  Created by Zach Smith on 4/15/25.
//


import SwiftUI
import GoogleSignIn

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var state: WorkoutViewState = .loading
    
    private let repository: WorkoutRepository
    private let selectedWeek: String

    init(repository: WorkoutRepository, selectedWeek: String) {
        self.repository = repository
        self.selectedWeek = selectedWeek
    }
    
    func getWorkouts() async {
        state = .loading
        do {
            let workouts = try await repository.fetchSchedule(for: selectedWeek)
            print(workouts)
            state = .data(workouts)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

enum WorkoutViewState: Equatable {
    case loading
    case error(String)
    case data(Schedule)
}
