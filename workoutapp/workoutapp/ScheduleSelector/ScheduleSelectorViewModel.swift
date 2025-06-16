//
//  ScheduleSelectorViewModel.swift
//  workoutapp
//
//  Created by Zach Smith on 4/16/25.
//

import SwiftUI

@MainActor
final class ScheduleSelectorViewModel: ObservableObject {
    @Published var state: ScheduleSelectorState = .loading
    
    private let repository: WorkoutRepository

    init(repository: WorkoutRepository) {
        self.repository = repository
    }

    func loadWeeks() async {
        state = .loading
        do {
            let schedules = try await repository.fetchSchedules()
            AppLogger.info("Loaded \(schedules.count) schedules", category: .general)
            state = .data(weeks: schedules.map(\.name))
        } catch {
            AppLogger.error("Failed to load schedules", error: error, category: .networking)
            state = .error(error.localizedDescription)
        }
    }

    func retry() async {
        AppLogger.info("Retrying to load workout weeks", category: .general)
        await loadWeeks()
    }
}

enum ScheduleSelectorState: Equatable {
    case loading
    case error(String)
    case data(weeks: [String])
}
