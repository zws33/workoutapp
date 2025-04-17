import SwiftUI
import GoogleSignIn

struct WeekSelectorView: View {
    @StateObject private var viewModel: WeekSelectorViewModel

    init(repository: WorkoutRepository) {
        _viewModel = StateObject(wrappedValue: WeekSelectorViewModel(repository: repository))
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading Weeks...")
                    .padding()
            } else if let error = viewModel.error {
                VStack(spacing: 12) {
                    Text("Failed to load weeks: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        viewModel.retry()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                List(viewModel.weeks, id: \.self) { week in
                    HStack {
                        Text(week)
                            .fontWeight(week == viewModel.selectedWeek ? .semibold : .regular)
                        Spacer()
                        if week == viewModel.selectedWeek {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.select(week: week)
                    }
                }
            }
        }
        .navigationTitle("Select a Week")
        .task {
            await viewModel.loadWeeks()
        }
    }
}