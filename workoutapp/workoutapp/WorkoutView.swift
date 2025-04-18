//
//  ExerciseSection.swift
//  workoutapp
//
//  Created by Zach Smith on 4/13/25.
//

import SwiftUI

struct WorkoutView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @State private var selectedDay: String?
    
    init(workoutRepository: WorkoutRepository, selectedWeek: String) {
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(repository: workoutRepository, selectedWeek: selectedWeek))
    }
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .Loading:
                ProgressView("Loading workouts...")
                    .padding()
            case .Error(let string):
                errorView(string)
            case .Data(let dictionary):
                if dictionary.isEmpty {
                    loadButton("Load Workout Data")
                } else {
                    VStack {
                        dayPicker(days: dictionary.keys.sorted())
                        if let selected = selectedDay,
                           let exercises = dictionary[selected] {
                            exerciseList(exercises: exercises)
                        } else {
                            Text("Select a workout day")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            Spacer()
        }
        .task {
            await viewModel.getWorkouts()
        }
        .onChange(of: viewModel.state) {
            if case let .Data(dictionary) = viewModel.state,
               selectedDay == nil {
                selectedDay = dictionary.keys.sorted().first
            }
        }
        .padding()
    }
    
    // Day picker
    private func dayPicker(days: [String]) -> some View {
        Picker("Select Workout Day", selection: $selectedDay) {
            Text("Select a workout day").tag(nil as String?)
            ForEach(days, id: \.self) { day in
                Text(day).tag(day as String?)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
    
    // Exercises List
    private func exerciseList(exercises: [Exercise]) -> some View {
        List {
            ForEach(exercises){ exercise in
                ExerciseRow(exercise: exercise)
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
            Task {
                await viewModel.getWorkouts()
            }
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
        WorkoutView(workoutRepository: FakeWorkoutRepository(), selectedWeek: "Week 1")
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
