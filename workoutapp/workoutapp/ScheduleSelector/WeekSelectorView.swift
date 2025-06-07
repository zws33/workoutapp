//
//  WeekSelectorView.swift
//  workoutapp
//
//  Created by Zach Smith on 4/16/25.
//


import SwiftUI

struct WeekSelectorView: View {
    @StateObject private var viewModel: WeekSelectorViewModel
    private let repository: WorkoutRepository
    
    init(repository: WorkoutRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: WeekSelectorViewModel(repository: repository))
    }
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading Weeks...")
                    .padding()
            case .error(let error):
                VStack(spacing: 12) {
                    Text("Failed to load weeks: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        Task {
                            await viewModel.retry()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            case .data(let weeks):
                List(weeks, id: \.self) { week in
                    NavigationLink {
                        WorkoutView(workoutRepository: repository, selectedWeek: week)
                    } label: {
                        weekRow(week: week)
                    }
                }
            }
        }
        .navigationTitle("Select a Week")
        .task {
            await viewModel.loadWeeks()
        }
    }
    func weekRow(week: String) -> some View {
        HStack {
            Text(week)
            Spacer()
        }
        .contentShape(Rectangle())
    }
}
