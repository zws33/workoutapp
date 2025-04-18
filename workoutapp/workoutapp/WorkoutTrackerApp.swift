import SwiftUI
import GoogleSignIn

// MARK: - App Entry Point

@main
struct WorkoutTrackerApp: App {
    @StateObject var authViewModel = AuthManager()
    let workoutRepository = WorkoutRepositoryImpl()
    
    var body: some Scene {
        WindowGroup {
            ContentView(workoutRepository: workoutRepository)
                .environmentObject(authViewModel)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    let workoutRepository: WorkoutRepository
    
    var body: some View {
        switch authManager.authState {
        case .signedOut:
            SignInView()
        case .signedIn:
            NavigationStack {
                ZStack {
                    WeekSelectorView(repository: workoutRepository)
                }
                .navigationTitle("My Workouts")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Sign Out") {
                            authManager.signOut()
                        }
                    }
                }
            }
        }
    }
}
