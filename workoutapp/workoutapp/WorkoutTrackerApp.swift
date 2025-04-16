import SwiftUI
import GoogleSignIn

// MARK: - App Entry Point

@main
struct WorkoutTrackerApp: App {
    @StateObject var authViewModel = AuthViewModel()
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

// MARK: - Authentication View Model

enum AuthState {
    case signedOut
    case signedIn
}
class AuthViewModel: ObservableObject {
    @Published var authState = AuthState.signedOut
    
    init() {
        // Restore previous sign-in if it exists
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                self?.authState = user != nil ? .signedIn : .signedOut
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
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        ) { result, error in
            self.authState = result?.user != nil ? .signedIn : .signedOut
            completion(error == nil)
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.authState = .signedOut
    }
}

// MARK: - Main Content View

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let workoutRepository: WorkoutRepository
    
    var body: some View {
        switch authViewModel.authState {
        case .signedOut:
            SignInView()
        case .signedIn:
            NavigationStack {
                ZStack {
                    WorkoutView(viewModel: WorkoutViewModel(repository: workoutRepository))
                }
                .navigationTitle("My Workouts")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Sign Out") {
                            authViewModel.signOut()
                        }
                    }
                }
            }
        }
    }
}
