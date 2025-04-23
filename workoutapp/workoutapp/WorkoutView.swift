//
//  ExerciseSection.swift
//  workoutapp
//
//  Created by Zach Smith on 4/13/25.
//

import SwiftUI

struct WorkoutView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @State private var selectedDay: WorkoutDay?
    
    init(workoutRepository: WorkoutRepository, selectedWeek: String) {
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(repository: workoutRepository, selectedWeek: selectedWeek))
    }
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading workouts...")
                    .padding()
            case .error(let string):
                errorView(string)
            case .data(let dictionary):
                if dictionary.isEmpty {
                    loadButton("Load Workout Data")
                } else {
                    VStack {
                        dayPicker(days:  WorkoutDay.allCases)
                        if let selected = selectedDay,
                           let exercises = dictionary[selected] {
                            ExerciseListView(exercises: exercises)
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
            if case let .data(dictionary) = viewModel.state,
               selectedDay == nil {
                selectedDay = dictionary.keys.sorted().first
            }
        }
        .padding()
    }
    
    private func dayPicker(days: [WorkoutDay]) -> some View {
        Picker("Select Workout Day", selection: $selectedDay) {
            Text("Select a workout day").tag(nil as String?)
            ForEach(days, id: \.self) { day in
                Text(day.rawValue).tag(day)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
    
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
struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView(workoutRepository: FakeWorkoutRepository(), selectedWeek: "Week 1")
    }
}

struct ExerciseListView: View {
    // Input property - exercises to display
    let exercises: [Exercise]
    let Keys = ["Primary", "Secondary", "Cardio", "Core"]
    
    var body: some View {
        let grouped = Dictionary(grouping: exercises, by: {$0.group})
        List {
            ForEach(Keys, id: \.self) { key in
                if let exercises = grouped[key] {
                    ExerciseSection(title: key, exercises: exercises)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

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

struct ExerciseRow: View {
    let exercise: Exercise
    @State private var isExpanded = false

    fileprivate func exerciseLabel() -> VStack<TupleView<(Text, some View)>> {
        return VStack(alignment: .leading, spacing: 2) {
            Text(exercise.name)
                .font(.headline)
            
            HStack {
                Text("Sets: \(exercise.sets)")
                let reps = exercise.reps.isEmpty ? "-" : exercise.reps
                Text("Reps: \(reps)")
                if !exercise.weight.isEmpty {
                    Text("Weight: \(exercise.weight)")
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.vertical, 4)
        }
    }
    
    var body: some View {
        if !exercise.notes.isEmpty {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    Text(exercise.notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                        .transition(.opacity)
                    
                },
                label: {
                    exerciseLabel()
                }
            )
            .animation(.easeInOut(duration: 0.25), value: isExpanded)
        } else {
            exerciseLabel()
                
        }
    }
}

// Preview provider
struct ExerciseListView_Previews: PreviewProvider {
    
    static var previews: some View {
        let exercises = [
            Exercise(
                day: "1", group: "Primary", name: "Push ups", sets: "3",reps: "10", weight: "30lbs", notes: "elbows in"
            ), Exercise(
                day: "1", group: "Secondary", name: "Lunges", sets: "3",reps: "10", weight: "30lbs", notes: ""
            ),
            Exercise(
                day: "1", group: "Cardio", name: "400m Run", sets: "3",reps: "10", weight: "30lbs", notes: ""
            )
        ]
        ExerciseListView(exercises: exercises)
    }
}
