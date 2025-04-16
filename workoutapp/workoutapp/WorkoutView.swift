//
//  ExerciseSection.swift
//  workoutapp
//
//  Created by Zach Smith on 4/13/25.
//

import SwiftUI

struct WorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var selectedDay: String?

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading workouts...")
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                errorView(errorMessage)
            } else if viewModel.workouts.isEmpty {
                loadButton("Load Workout Data")
            } else {
                dayPicker
                exerciseList
            }

            Spacer()
        }
        .task {
            await viewModel.getData()
        }
        .onChange(of: viewModel.workouts) {
            if selectedDay == nil, !viewModel.workouts.isEmpty {
                selectedDay = viewModel.workouts.keys.sorted().first
            }
        }
        .padding()
    }

    // Day picker
    private var dayPicker: some View {
        Picker("Select Workout Day", selection: $selectedDay) {
            Text("Select a workout day").tag(nil as String?)
            ForEach(viewModel.workouts.keys.sorted(), id: \.self) { day in
                Text(day).tag(day as String?)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }

    // Exercises List
    private var exerciseList: some View {
        List {
            if let day = selectedDay, let exercises = viewModel.workouts[day] {
                ForEach(exercises){ exercise in
                    ExerciseRow(exercise: exercise)
                }
            } else {
                Text("Select a workout day")
                    .foregroundColor(.secondary)
            }
        }
    }

    // Error view helper
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text("Error")
                .font(.headline)
            Text(message)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            loadButton("Try Again")
        }
    }

    // Load button helper
    private func loadButton(_ label: String) -> some View {
        Button(label) {
            Task { await viewModel.getData() }
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}

@MainActor
struct WorkoutSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView(viewModel: mockViewModel)
    }

    static var mockViewModel: WorkoutViewModel {
        let vm = WorkoutViewModel(repository: FakeWorkoutRepository())
        vm.workouts = [
            "Day 1": [
                Exercise(day: "Day 1", group: "Push", name: "Bench Press", sets: "3", reps: "10", weight: "135", notes: "Focus on control"),
                Exercise(day: "Day 1", group: "Push", name: "Overhead Press", sets: "3", reps: "8", weight: "95", notes: "")
            ],
            "Day 2": [
                Exercise(day: "Day 2", group: "Pull", name: "Deadlift", sets: "5", reps: "5", weight: "225", notes: "Keep back tight")
            ]
        ]
        return vm
    }
}

// Simple row component for each exercise
struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)
                .font(.headline)
            
            HStack {
                Text("Sets: \(exercise.sets)")
                Text("Reps: \(exercise.reps)")
                if !exercise.weight.isEmpty {
                    Text("Weight: \(exercise.weight)")
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            if !exercise.notes.isEmpty {
                Text(exercise.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

// Exercise list section
struct ExerciseSection: View {
    let title: String
    let exercises: [Exercise]
    
    var body: some View {
        Section(header: Text(title).font(.title3).bold()) {
            ForEach(exercises) { exercise in
                ExerciseRow(exercise: exercise)
            }
        }
    }
}

// Main exercise list view
struct ExerciseListView: View {
    // Input property - exercises to display
    let exercises: [Exercise]

    var body: some View {
        let grouped = Dictionary(grouping: exercises, by: {$0.group})
        let keys = grouped.keys.sorted()
        List {
            // Creates each section
            ForEach(keys, id: \.self) { group in
                Section(header: Text(group)) {
                    // Creates each row within a section
                    ForEach(grouped[group]!) { exercise in
                        ExerciseRow(exercise: exercise)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

// Preview provider
struct ExerciseListView_Previews: PreviewProvider {
    
    static var previews: some View {
        ExerciseListView(exercises: [exercise])
    }
}


let exercise = Exercise(
    day: "1", group: "primary", name: "Push ups", sets: "3",reps: "10", weight: "30lbs", notes: "elbows in"
)
