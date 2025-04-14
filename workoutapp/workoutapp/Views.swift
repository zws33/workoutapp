//
//  ExerciseSection.swift
//  workoutapp
//
//  Created by Zach Smith on 4/13/25.
//

import SwiftUI

struct WorkoutSelectorView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var selectedDay: String?
    
    var body: some View {
        VStack {
            // Day selector
            dayPicker
            
            // Exercise list for selected day
            exerciseList
            
            Spacer()
        }
        .onAppear {
            // Load data when view appears
            if viewModel.workouts.isEmpty {
                viewModel.getData()
            }
            
            // Set default selection to first day if available
            if selectedDay == nil, let firstDay = viewModel.workouts.keys.sorted().first {
                selectedDay = firstDay
            }
        }
    }
    
    // Selector component
    private var dayPicker: some View {
        Picker("Select Workout Day", selection: $selectedDay) {
            Text("Select a day").tag(nil as String?)
            
            ForEach(viewModel.workouts.keys.sorted(), id: \.self) { day in
                Text(day).tag(day as String?)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .padding()
        .disabled(viewModel.workouts.isEmpty)
    }
    
    // List component that displays exercises for the selected day
    private var exerciseList: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading workouts...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.workouts.isEmpty {
                Text("No workouts available")
                    .foregroundColor(.secondary)
                    .padding()
            } else if let selectedDay = selectedDay, let exercises = viewModel.workouts[selectedDay] {
                List {
                    ForEach(exercises) { exercise in
                        ExerciseRow(exercise: exercise)
                    }
                }
            } else {
                Text("Select a workout day")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
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
