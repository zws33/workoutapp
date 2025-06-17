//
//  ScheduleSelectorView.swift
//  workoutapp
//
//  Created by Zach Smith on 4/16/25.
//

import SwiftUI

struct ScheduleSelectorView: View {
    @StateObject private var viewModel: ScheduleSelectorViewModel
    private let repository: WorkoutRepository
    
    init(repository: WorkoutRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: ScheduleSelectorViewModel(repository: repository))
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading workout plans…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .error(let errorMessage):
                ErrorPlaceholder(msg: errorMessage) {
                    await viewModel.refreshSchedules()
                }
                
            case .data(let weeks):
                List(weeks, id: \.self) { week in
                    NavigationLink {
                        WorkoutView(workoutRepository: repository, selectedWeek: week)
                    } label: {
                        WeekRow(week: week)
                    }
                }
                .refreshable {
                    await viewModel.refreshSchedules()
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .task { await viewModel.loadSchedules() }
        .animation(.default, value: viewModel.state)
    }
}

struct WeekRow: View {
    let week: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(week)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text("Workout plan")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

// MARK: - Previews
#Preview("ScheduleSelectorView") {
    NavigationStack {
        ScheduleSelectorView(repository: FakeWorkoutRepository())
            .navigationTitle("My Workouts")
    }
}

#Preview("WeekRow") {
    List {
        WeekRow(week: "Week 1")
        WeekRow(week: "Week 2")
        WeekRow(week: "Advanced Program")
    }
    .listStyle(.insetGrouped)
}
