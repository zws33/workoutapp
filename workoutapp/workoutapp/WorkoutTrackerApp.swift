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

// MARK: - Sign In View

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSigningIn = false
    @State private var signInError: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            if isSigningIn {
                ProgressView("Signing in...")
            } else {
                Image(systemName: "figure.walk")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)
                
                Text("Workout Tracker")
                    .font(.largeTitle)
                    .bold()
                
                if let error = signInError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
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
            }
        }
        .padding()
    }
}

func prettyPrintData(data: Data) {
    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
        print(String(decoding: jsonData, as: UTF8.self))
    } else {
        print("json data malformed")
    }
}
