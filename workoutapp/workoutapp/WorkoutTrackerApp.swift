import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST_Sheets

// MARK: - App Entry Point

@main
struct WorkoutTrackerApp: App {
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

// MARK: - Authentication View Model

class AuthViewModel: ObservableObject {
    @Published var isSignedIn = false
    
    private let clientID = "951785297505-leo3cs9atmgrl42or2clttjer184hl4f.apps.googleusercontent.com"
    
    init() {
        // Restore previous sign-in if it exists
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                self?.isSignedIn = user != nil
            }
        }
    }
    
    func signIn(completion: @escaping (Bool) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            completion(false)
            return
        }
        
        // Configure GIDSignIn and sign in
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let result = result else {
                print("Error signing in: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            
            self?.isSignedIn = true
            completion(true)
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isSignedIn = false
    }
}

// MARK: - Main Content View

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var workoutViewModel = WorkoutViewModel(spreadsheetId: "YOUR_SPREADSHEET_ID")
    
    var body: some View {
        if !authViewModel.isSignedIn {
            SignInView()
        } else {
            WorkoutListView(viewModel: workoutViewModel)
        }
    }
}

// MARK: - Sign In View

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSigningIn = false
    @State private var signInError: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.walk")
                .font(.system(size: 70))
                .foregroundColor(.blue)
            
            Text("Workout Tracker")
                .font(.largeTitle)
                .bold()
            
            Text("Sign in with your Google account to access your workout data from Google Sheets")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                isSigningIn = true
                authViewModel.signIn { success in
                    isSigningIn = false
                    if !success {
                        signInError = "Failed to sign in with Google"
                    }
                }
            }) {
                HStack {
                    Image(systemName: "person.circle.fill")
                    Text("Sign in with Google")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(isSigningIn)
            .padding(.top, 20)
            
            if isSigningIn {
                ProgressView("Signing in...")
            }
            
            if let error = signInError {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
        }
        .padding()
    }
}

// MARK: - Workout List View

struct WorkoutListView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading workout data...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Text("Error")
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            viewModel.loadWorkoutFromGoogleSheets()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                } else if let program = viewModel.workoutProgram {
                    List {
                        ForEach(program.sessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                Text(session.name)
                                    .font(.headline)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Text("No workout data loaded")
                            .font(.headline)
                        Button("Load Workout Data") {
                            viewModel.loadWorkoutFromGoogleSheets()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .navigationTitle("My Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign Out") {
                        authViewModel.signOut()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.loadWorkoutFromGoogleSheets()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                if viewModel.workoutProgram == nil && !viewModel.isLoading {
                    viewModel.loadWorkoutFromGoogleSheets()
                }
            }
        }
    }
}

// MARK: - Session Detail View

struct SessionDetailView: View {
    let session: WorkoutSession
    
    var body: some View {
        List {
            // Regular exercises
            if !session.exercises.isEmpty {
                Section(header: Text("Exercises")) {
                    ForEach(session.exercises) { exercise in
                        ExerciseRow(exercise: exercise)
                    }
                }
            }
            
            // Metcons
            ForEach(session.metcons) { metcon in
                Section(header: Text(metcon.title)) {
                    Text(metcon.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(metcon.exercises) { exercise in
                        ExerciseRow(exercise: exercise)
                    }
                }
            }
        }
        .navigationTitle(session.name)
    }
}

// MARK: - Exercise Row

struct ExerciseRow: View {
    let exercise: WorkoutExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)
                .font(.headline)
            
            // Only show sets/reps/weight if they're not empty
            if !exercise.sets.isEmpty || !exercise.reps.isEmpty || !exercise.weight.isEmpty {
                HStack(spacing: 12) {
                    if !exercise.sets.isEmpty {
                        Label("\(exercise.sets) sets", systemImage: "number.circle")
                            .font(.footnote)
                    }
                    
                    if !exercise.reps.isEmpty {
                        Label("\(exercise.reps) reps", systemImage: "repeat")
                            .font(.footnote)
                    }
                    
                    if !exercise.weight.isEmpty {
                        Label("\(exercise.weight)", systemImage: "scalemass")
                            .font(.footnote)
                    }
                }
            }
            
            // Show notes if available
            if !exercise.notes.isEmpty {
                Text(exercise.notes)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

// Sample Preview
struct ExerciseRow_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseRow(exercise: WorkoutExercise(
            name: "Bench Press",
            sets: "3",
            reps: "10",
            weight: "135 lbs",
            notes: "Focus on form"
        ))
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

// MARK: - Data Models

// Main workout program struct
struct WorkoutProgram: Identifiable, Codable {
    let id = UUID()
    let title: String        // e.g., "Zach Smith Phase 2 Week 2"
    var sessions: [WorkoutSession]
}

// Individual workout session (e.g., "Day 1 Upper", "Day 2 Lower", etc.)
struct WorkoutSession: Identifiable, Codable {
    let id = UUID()
    let name: String         // e.g., "Day 1 Upper", "Day 2 Lower"
    var exercises: [WorkoutExercise]
    var metcons: [Metcon]    // Metabolic conditioning / circuit components
}

// Individual exercise within a workout session
struct WorkoutExercise: Identifiable, Codable {
    let id = UUID()
    let name: String         // e.g., "Seated DB Arnold Press"
    let sets: String         // Using String to accommodate various formats
    let reps: String         // Using String for complex patterns like "10"-10"-6"
    let weight: String       // Using String for values like "40 (35)"
    let notes: String
    var isMetconExercise: Bool = false // Flag to indicate if it's part of a metcon
    
    // Computed property to display formatted weight, handling empty cases
    var formattedWeight: String {
        return weight.isEmpty ? "Bodyweight" : weight
    }
}

// Metcon (Metabolic Conditioning) section
struct Metcon: Identifiable, Codable {
    let id = UUID()
    let title: String        // e.g., "METCON", "AMRAP 10 min"
    var description: String  // e.g., "4 Rounds for time"
    var exercises: [WorkoutExercise]
    var score: String        // For tracking performance
}

// MARK: - Parsing Logic

class WorkoutParser {
    
    // Parse Google Sheets API data into WorkoutProgram
    static func parseWorkoutProgram(from sheetsData: [[String]], title: String) -> WorkoutProgram {
        var program = WorkoutProgram(title: title, sessions: [])
        var currentSession: WorkoutSession?
        var currentMetcon: Metcon?
        var exercises: [WorkoutExercise] = []
        var metconExercises: [WorkoutExercise] = []
        
        // Get headers from the first row
        guard let headers = sheetsData.first, !headers.isEmpty else {
            return program
        }
        
        // Find column indices
        let exerciseIndex = 0 // Assuming first column is exercise name
        let setsIndex = headers.firstIndex(of: "Sets") ?? 1
        let repsIndex = headers.firstIndex(of: "Reps") ?? 2
        let weightIndex = headers.firstIndex(of: "Weight") ?? 3
        let notesIndex = headers.firstIndex(of: "Notes") ?? 4
        
        // Process data rows (skip header row)
        for i in 1..<sheetsData.count {
            let row = sheetsData[i]
            guard row.count >= max(exerciseIndex, setsIndex, repsIndex, weightIndex, notesIndex) + 1 else {
                continue
            }
            
            let exercise = row[exerciseIndex]
            let sets = row.indices.contains(setsIndex) ? row[setsIndex] : ""
            let reps = row.indices.contains(repsIndex) ? row[repsIndex] : ""
            let weight = row.indices.contains(weightIndex) ? row[weightIndex] : ""
            let notes = row.indices.contains(notesIndex) ? row[notesIndex] : ""
            
            // Skip empty rows
            if exercise.isEmpty && sets.isEmpty && reps.isEmpty {
                continue
            }
            
            // Detect new session (Day 1, Day 2, etc.)
            if exercise.lowercased().contains("day") && currentSession != nil {
                // Save previous session
                if let session = currentSession {
                    // Add any pending metcon
                    if let metcon = currentMetcon, !metconExercises.isEmpty {
                        var updatedMetcon = metcon
                        updatedMetcon.exercises = metconExercises
                        var updatedSession = session
                        updatedSession.metcons.append(updatedMetcon)
                        currentSession = updatedSession
                        metconExercises = []
                        currentMetcon = nil
                    }
                    
                    var updatedSession = session
                    updatedSession.exercises = exercises
                    program.sessions.append(updatedSession)
                }
                
                // Start new session
                currentSession = WorkoutSession(name: exercise, exercises: [], metcons: [])
                exercises = []
                continue
            }
            
            // Detect METCON sections
            if exercise.contains("METCON") || exercise.contains("AMRAP") || exercise.contains("E3MOM") {
                // Save any pending exercises to the current session
                if !exercises.isEmpty && currentSession != nil {
                    var updatedSession = currentSession!
                    updatedSession.exercises = exercises
                    currentSession = updatedSession
                    exercises = []
                }
                
                // Start new metcon
                currentMetcon = Metcon(title: exercise, description: "", exercises: [], score: "")
                continue
            }
            
            // Handle special metcon description rows (like "4 Rounds for time")
            if currentMetcon != nil && exercise.contains("Round") {
                var updatedMetcon = currentMetcon!
                updatedMetcon.description = exercise
                currentMetcon = updatedMetcon
                continue
            }
            
            // Create exercise object
            let workoutExercise = WorkoutExercise(
                name: exercise,
                sets: sets,
                reps: reps,
                weight: weight,
                notes: notes,
                isMetconExercise: currentMetcon != nil
            )
            
            // Add to appropriate collection
            if currentMetcon != nil {
                metconExercises.append(workoutExercise)
            } else {
                exercises.append(workoutExercise)
            }
        }
        
        // Add final session
        if let session = currentSession {
            // Add any pending metcon
            if let metcon = currentMetcon, !metconExercises.isEmpty {
                var updatedMetcon = metcon
                updatedMetcon.exercises = metconExercises
                var updatedSession = session
                updatedSession.metcons.append(updatedMetcon)
                currentSession = updatedSession
            }
            
            var updatedSession = session
            updatedSession.exercises = exercises
            program.sessions.append(updatedSession)
        }
        
        return program
    }
    
    // Helper function to convert Google Sheets API response to our required format
    static func parseGoogleSheetsResponse(_ response: GTLRSheets_ValueRange) -> [[String]] {
        guard let values = response.values as? [[String]] else {
            return []
        }
        return values
    }
}

// MARK: - Google Sheets Integration

// ViewModel for handling Google Sheets data
class WorkoutViewModel: ObservableObject {
    @Published var workoutProgram: WorkoutProgram?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let sheetsService = GTLRSheetsService()
    private let spreadsheetId: String
    
    init(spreadsheetId: String) {
        self.spreadsheetId = spreadsheetId
        configureService()
    }
    
    private func configureService() {
        // Configure the sheets service with OAuth token
        if let user = GIDSignIn.sharedInstance.currentUser {
            sheetsService.authorizer = user.fetcherAuthorizer
        }
    }
    
    func loadWorkoutFromGoogleSheets(sheetName: String = "Sheet1", range: String = "A:Z") {
        guard GIDSignIn.sharedInstance.currentUser != nil else {
            self.errorMessage = "Not signed in to Google. Please sign in first."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Create the query to fetch the spreadsheet values
        let fullRange = "\(sheetName)!\(range)"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range: fullRange)
        
        sheetsService.executeQuery(query) { [weak self] (ticket, result, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Error fetching data: \(error.localizedDescription)"
                    return
                }
                
                guard let valueRange = result as? GTLRSheets_ValueRange,
                      let values = valueRange.values as? [[String]] else {
                    self?.errorMessage = "Invalid data format received from Google Sheets"
                    return
                }
                
                // Create workout program from sheets data
                let program = WorkoutParser.parseWorkoutProgram(
                    from: values,
                    title: "Workout Program"
                )
                
                // Update published property
                self?.workoutProgram = program
            }
        }
    }
}
