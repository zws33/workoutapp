import SwiftUI
import GoogleSignIn

class AuthManager: ObservableObject {
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