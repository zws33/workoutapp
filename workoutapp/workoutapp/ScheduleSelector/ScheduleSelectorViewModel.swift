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

    func loadSchedules() async {
        state = .loading
        do {
            let schedules = try await repository.getSchedules()
            state = .data(weeks: schedules.map(\.name))
        } catch {
            AppLogger.error("Failed to load schedules", error: error, category: .networking)
            state = .error(error.localizedDescription)
        }
    }
    
    func refreshSchedules() async {
        AppLogger.info("Attempting to sync workout weeks via pull to refresh", category: .general)
        // Don't set state = .loading here - let pull-to-refresh handle it
        do {
            try await repository.syncSchedulesWithRemote()
            let schedules = try await repository.getSchedules()
            state = .data(weeks: schedules.map(\.name))
        } catch {
            AppLogger.error("Failed to sync schedules via pull to refresh", error: error, category: .general)
            state = .error(error.localizedDescription)
        }
    }
}

enum ScheduleSelectorState: Equatable {
    case loading
    case error(String)
    case data(weeks: [String])
}
