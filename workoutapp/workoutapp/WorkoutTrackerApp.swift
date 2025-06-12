import SwiftUI
import GoogleSignIn
import FirebaseCore

// MARK: - App Entry Point

@main
struct WorkoutTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var authManager = AuthManagerImpl.shared
    
    let repository: WorkoutRepository
    
    init() {
        self.repository = WorkoutRepositoryImpl(authManager: AuthManagerImpl.shared)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(repository: repository)
                .environmentObject(authManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManagerImpl
    let repository: WorkoutRepository
    
    var body: some View {
        switch authManager.authState {
        case .signedOut:
            SignInView()
        case .signedIn:
            NavigationStack {
                ZStack {
                    WeekSelectorView(repository: repository)
                }
                .navigationTitle("My Workouts")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Sign Out") {
                            do {
                                try authManager.signOut()
                            } catch {
                                // Handle error (log it, show alert, etc.)
                                print("Sign-out failed:", error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }
}
