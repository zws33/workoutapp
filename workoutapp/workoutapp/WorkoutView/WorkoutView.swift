import SwiftUI

struct WorkoutView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @State private var selectedDay: String?
    
    init(workoutRepository: WorkoutRepository, selectedWeek: String) {
        _viewModel = StateObject(
            wrappedValue: .init(
                repository: workoutRepository,
                selectedWeek: selectedWeek
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading workouts…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .error(let msg):
                    ErrorPlaceholder(msg: msg) {
                        await viewModel.getWorkouts()
                    }

                case .data(let group):
                    ExerciseList(
                        workouts: group.workouts,
                        selectedDay: $selectedDay
                    )
                    .navigationTitle(group.name) 
                }
            }
            .task { await viewModel.getWorkouts() }
            .animation(.default, value: viewModel.state)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu(selectedDay != nil ? "Day \(selectedDay!)" : "Select Day") {
                        ForEach(groupedDays, id: \.self) { day in
                            Button("Day \(day)") { selectedDay = day }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .onChange(of: viewModel.state) { oldState, newState in
                if case let .data(workoutGroup) = newState,
                   selectedDay == nil {
                    selectedDay = workoutGroup.workouts.first?.day
                }
            }
        }
    }

    private var groupedDays: [String] {
        if case let .data(g) = viewModel.state {
            g.workouts.map(\.day).sorted()
        } else { [] }
    }
}

struct ExerciseList: View {
    let workouts: [Workout]
    @Binding var selectedDay: String?

    var body: some View {
        if let day = selectedDay,
           let workout = workouts.first(where: { $0.day == day }) {

            List {
                ForEach(sortedSections(in: workout), id: \.self) { key in
                    if let items = workout.exercises[key], !items.isEmpty {
                        Section(key.uppercased()) {
                            ForEach(items, id: \.name) {
                                ExerciseRow(exercise: $0)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        } else {
            ContentUnavailableView("Select a workout day",
                                   systemImage: "calendar")
        }
    }

    private func sortedSections(in workout: Workout) -> [String] {
        let priority = ["Primary", "Secondary", "Cardio", "Core"]
        return priority.filter { workout.exercises.keys.contains($0) }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    @State private var open = false

    var body: some View {
        if !exercise.notes.isEmpty {
            // Show DisclosureGroup with chevron when there are notes
            DisclosureGroup(isExpanded: $open) {
                Text(exercise.notes)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
            } label: {
                ExerciseRowContent(exercise: exercise)
            }
            .disclosureGroupStyle(.automatic)
        } else {
            // Show plain content without chevron when no notes
            ExerciseRowContent(exercise: exercise)
        }
    }
}

// Extract common content to avoid duplication
struct ExerciseRowContent: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(exercise.name)
                .font(.title3)
                .fontWeight(.bold)

            Text(metaLine)
                .font(.body)
                .foregroundColor(.secondary)
                .accessibilityLabel(metaVoiceOver)
        }
        .padding(.vertical, 6)   // Bigger tap target
    }

    private var metaLine: String {
        [
            "\(exercise.sets) sets",
            exercise.reps > 0 ? "\(exercise.reps) reps" : nil,
            !exercise.weight.isEmpty ? exercise.weight : nil
        ]
            .compactMap { $0 }
            .joined(separator: " · ")
    }

    private var metaVoiceOver: String {
        [
            "\(exercise.sets) sets",
            exercise.reps > 0 ? "\(exercise.reps) reps" : nil,
            !exercise.weight.isEmpty ? "\(exercise.weight) weight" : nil
        ]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}


// MARK: – Error placeholder
struct ErrorPlaceholder: View {
    let msg: String
    let retry: () async -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.octagon")
                .font(.largeTitle)
                .foregroundColor(.red)

            Text(msg)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task { await retry() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews
#Preview("WorkoutView") {
    WorkoutView(
        workoutRepository: FakeWorkoutRepository(),
        selectedWeek: "Week 1"
    )
}

#Preview("ExerciseRow") {
    VStack(spacing: 12) {
        ExerciseRow(exercise: Exercise.sampleExercises[0])
        ExerciseRow(exercise: Exercise.sampleCardioExercises[0])
        ExerciseRow(exercise: Exercise.sampleCoreExercises[0])
    }
    .padding()
}

#Preview("ErrorPlaceholder") {
    VStack(spacing: 12) {
        ErrorPlaceholder(msg: "Couldn't connect to server", retry: {})
    }
    .padding()
}

// MARK: - Preview Data
extension Exercise {
    static let sampleExercises = [
        Exercise(
            name: "Push-ups",
            sets: 3,
            reps: 15,
            weight: "Bodyweight",
            notes: "Keep elbows close to body"
        ),
        Exercise(
            name: "Bench Press",
            sets: 4,
            reps: 8,
            weight: "135 lbs",
            notes: ""
        ),
        Exercise(
            name: "Incline Dumbbell Press",
            sets: 3,
            reps: 12,
            weight: "40 lbs",
            notes: "Slow controlled movement"
        )
    ]
    
    static let sampleCardioExercises = [
        Exercise(
            name: "Treadmill Run",
            sets: 1,
            reps: 0,
            weight: "",
            notes: "20 minutes at moderate pace"
        ),
        Exercise(
            name: "Rowing Machine",
            sets: 3,
            reps: 0,
            weight: "",
            notes: "5 minutes each set"
        )
    ]
    
    static let sampleCoreExercises = [
        Exercise(
            name: "Plank",
            sets: 3,
            reps: 0,
            weight: "",
            notes: "Hold for 60 seconds"
        ),
        Exercise(
            name: "Russian Twists",
            sets: 3,
            reps: 20,
            weight: "15 lbs",
            notes: ""
        )
    ]
}
