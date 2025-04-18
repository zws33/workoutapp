//
//  WeekSelectorViewModel.swift
//  workoutapp
//
//  Created by Zach Smith on 4/16/25.
//


import SwiftUI
import GoogleSignIn

@MainActor
final class WeekSelectorViewModel: ObservableObject {
    @Published var state: WeekSelectorState = .loading
    @Published var weeks: [String] = []
    @Published var selectedWeek: String?
    @Published var isLoading: Bool = false
    @Published var error: Error?

    private let repository: WorkoutRepository

    init(repository: WorkoutRepository) {
        self.repository = repository
    }

    func loadWeeks() async {
        state = .loading
        do {
            let weeks = try await repository.fetchWeeks()
            state = .data(weeks: weeks)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func retry() async {
        await loadWeeks()
    }

    func select(week: String) {
        selectedWeek = week
    }
}

enum WeekSelectorState: Equatable {
    case loading
    case error(String)
    case data(weeks: [String])
}
