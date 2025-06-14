import SwiftUI

struct WorkoutView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @State private var selectedDay: String?
    
    init(workoutRepository: WorkoutRepository, selectedWeek: String) {
        _viewModel = StateObject(
            wrappedValue: .init(repository: workoutRepository, selectedWeek: selectedWeek)
        )
    }

    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading workouts...")
                    .padding()
            case .error(let string):
                errorView(string)
            case .data(let workoutGroup):
                    VStack {
                        dayPicker(days: workoutGroup.workouts.map(\.day).sorted())
                        if let selected = selectedDay,
                           let workoutDay = workoutGroup.workouts.first(where: { $0.day == selected }) {
                            ExerciseListView(exercises: workoutDay.exercises)
                        } else {
                            Text("Select a workout day")
                                .foregroundColor(.secondary)
                        }
                    }
            }
            Spacer()
        }
        .task {
            await viewModel.getWorkouts()
        }
        .onChange(of: viewModel.state) {
            if case let .data(workoutGroup) = viewModel.state,
               selectedDay == nil {
                selectedDay = workoutGroup.workouts.first?.day
            }
        }
        .padding()
    }
    
    private func dayPicker(days: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workout Day")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            if !days.isEmpty {
                Picker("Select Workout Day", selection: Binding(
                    get: { selectedDay ?? days.first ?? "" },
                    set: { selectedDay = $0 }
                )) {
                    ForEach(days, id: \.self) { day in
                        Text(day).tag(day)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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

struct ExerciseListView: View {
    let exercises: [String: [Exercise]]
    
    // Dynamically get sections from the exercises dictionary, prioritizing common ones
    private var sortedSections: [String] {
        let priorityOrder = ["Primary", "Secondary", "Cardio", "Core"]
        let availableSections = exercises.keys.filter { exercises[$0]?.isEmpty == false }
        
        // First add priority sections that exist
        return priorityOrder.filter { availableSections.contains($0) }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(sortedSections, id: \.self) { section in
                    if let sectionExercises = exercises[section], !sectionExercises.isEmpty {
                        ExerciseSection(title: section, exercises: sectionExercises)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct ExerciseSection: View {
    let title: String
    let exercises: [Exercise]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            ForEach(exercises, id: \.name) { exercise in
                ExerciseCardView(exercise: exercise)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
    }
}

struct ExerciseCardView: View {
    let exercise: Exercise
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    HStack(spacing: 16) {
                        Text("\(exercise.sets) sets")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if exercise.reps > 0 {
                            Text("\(exercise.reps) reps")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        if !exercise.weight.isEmpty {
                            Text(exercise.weight)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()
                
                if !exercise.notes.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundStyle(.tertiary)
                            .font(.subheadline)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if isExpanded && !exercise.notes.isEmpty {
                Divider()
                    .padding(.horizontal, 16)
                
                Text(exercise.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    @State private var open = false

    var body: some View {
        DisclosureGroup(isExpanded: $open) {
            if !exercise.notes.isEmpty {
                Text(exercise.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
            }
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .fontWeight(.semibold)
                    .font(.body)

                Text(metaLine)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityLabel(metaVoiceOver)
            }
            .padding(.vertical, 4)   // Bigger tap target
        }
        .disclosureGroupStyle(.automatic)
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

// MARK: - Preview Data
extension Exercise {
    static let sampleExercises = [
        Exercise(name: "Push-ups", sets: 3, reps: 15, weight: "Bodyweight", notes: "Keep elbows close to body"),
        Exercise(name: "Bench Press", sets: 4, reps: 8, weight: "135 lbs", notes: ""),
        Exercise(name: "Incline Dumbbell Press", sets: 3, reps: 12, weight: "40 lbs", notes: "Slow controlled movement")
    ]
    
    static let sampleCardioExercises = [
        Exercise(name: "Treadmill Run", sets: 1, reps: 0, weight: "", notes: "20 minutes at moderate pace"),
        Exercise(name: "Rowing Machine", sets: 3, reps: 0, weight: "", notes: "5 minutes each set")
    ]
    
    static let sampleCoreExercises = [
        Exercise(name: "Plank", sets: 3, reps: 0, weight: "", notes: "Hold for 60 seconds"),
        Exercise(name: "Russian Twists", sets: 3, reps: 20, weight: "15 lbs", notes: "")
    ]
}

// MARK: - Previews
#Preview("WorkoutView") {
    WorkoutView(workoutRepository: FakeWorkoutRepository(), selectedWeek: "Week 1")
}

#Preview("ExerciseListView") {
    ExerciseListView(exercises: [
        "Primary": Exercise.sampleExercises,
        "Cardio": Exercise.sampleCardioExercises,
        "Core": Exercise.sampleCoreExercises
    ])
}

#Preview("ExerciseSection") {
    ScrollView {
        VStack(spacing: 16) {
            ExerciseSection(title: "Primary", exercises: Exercise.sampleExercises)
            ExerciseSection(title: "Cardio", exercises: Exercise.sampleCardioExercises)
        }
    }
}

#Preview("ExerciseCardView") {
    VStack(spacing: 12) {
        ExerciseCardView(exercise: Exercise.sampleExercises[0])
        ExerciseCardView(exercise: Exercise.sampleCardioExercises[0])
        ExerciseCardView(exercise: Exercise.sampleCoreExercises[0])
    }
    .padding()
}
