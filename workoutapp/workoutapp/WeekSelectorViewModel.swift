import SwiftUI
import GoogleSignIn

@MainActor
final class WeekSelectorViewModel: ObservableObject {
    @Published var weeks: [String] = []
    @Published var selectedWeek: String?
    @Published var isLoading: Bool = false
    @Published var error: Error?

    private let repository: WorkoutRepository

    init(repository: WorkoutRepository) {
        self.repository = repository
    }

    func loadWeeks() async {
        isLoading = true
        error = nil
        do {
            let fetchedWeeks = try await repository.fetchWeeks()
            weeks = fetchedWeeks
            selectedWeek = fetchedWeeks.first
        } catch {
            self.error = error
        }
        isLoading = false
    }

    func retry() {
        Task {
            await loadWeeks()
        }
    }

    func select(week: String) {
        selectedWeek = week
    }
}