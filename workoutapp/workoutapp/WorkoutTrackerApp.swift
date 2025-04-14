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
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        ) { result, error in
            self.isSignedIn = error == nil
            completion(error == nil)
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
    @StateObject var workoutViewModel = WorkoutViewModel()
    
    var body: some View {
        if !authViewModel.isSignedIn {
            SignInView()
        } else {
            WorkoutListView(viewModel: workoutViewModel)
                .navigationTitle("Workout Plan")
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
        NavigationStack {
            ZStack {
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
                            viewModel.getData()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                } else if viewModel.workouts.count > 0 {
                    WorkoutSelectorView(viewModel: viewModel)
                } else {
                    VStack(spacing: 16) {
                        Text("No workout data loaded")
                            .font(.headline)
                        Button("Load Workout Data") {
                            viewModel.getData()
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
                        viewModel.getData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

// MARK: - WorkoutViewModel

// ViewModel for handling Google Sheets data
class WorkoutViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var workouts: [String: [Exercise]] = [:]
    
    func getData() {
        NetworkManager.shared.fetchSheetData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.workouts = data
                }
                
            case .failure(let error):
                print("Error fetching sheet names: \(error)")
            }
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case noData
    case decodingFailed(Error)
}

class NetworkManager {
    static let shared = NetworkManager()
    private let session = URLSession.shared
    
    private init() {}
    
    func fetchSheetData(completion: @escaping (Result<[String:[Exercise]], NetworkError>) -> Void) {
        let url = URL(string: "\(PROD_URL)/api/sheets/Week 1")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let idToken = GIDSignIn.sharedInstance.currentUser?.idToken else {
            completion(.failure(.invalidURL))
            return
        }
        print(idToken.description)
        
        request.addValue("Bearer \(idToken.tokenString)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let exercises = try decoder.decode([String:[Exercise]].self, from: data)
                
                // Return result on main thread for UI updates
                DispatchQueue.main.async {
                    completion(.success(exercises))
                }
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }
        task.resume()
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

// MARK: - Data model
struct Exercise: Codable, Identifiable {
    let day: String
    let group: String
    let name: String
    let sets: String
    let reps: String
    let weight: String
    let notes: String
    
    // Add an id for List to use
    var id: String {
        // Create a unique identifier by combining fields
        return "\(day)-\(group)-\(name)"
    }
    
    enum CodingKeys: String, CodingKey {
        case day = "Day"
        case group = "Group"
        case name = "Name"
        case sets = "Sets"
        case reps = "Reps"
        case weight = "Weight"
        case notes = "Notes"
    }
}

let DEV_URL = "http://localhost:3000"

let PROD_URL = "https://zwsmith.me"

