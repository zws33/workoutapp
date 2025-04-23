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
            let workouts = try await repository.fetchWorkouts(for: selectedWeek)
            state = .data(workouts)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

enum WorkoutViewState: Equatable {
    case loading
    case error(String)
    case data([WorkoutDay: [Exercise]])
}

enum WorkoutDay: String, CaseIterable, Hashable, Comparable {
    case dayOne = "Day 1"
    case dayTwo = "Day 2"
    case dayThree = "Day 3"

    static func < (lhs: WorkoutDay, rhs: WorkoutDay) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}
