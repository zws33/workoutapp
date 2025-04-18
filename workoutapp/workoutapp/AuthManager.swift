//
//  AuthManager.swift
//  workoutapp
//
//  Created by Zach Smith on 4/16/25.
//


import SwiftUI
import GoogleSignIn

protocol AuthManager {
    var authState: AuthState { get }
    var token: String? { get }
    func signIn(completion: @escaping (Bool) -> Void)
    func signOut()
}

class AuthManagerImpl: ObservableObject, AuthManager {
    static let shared = AuthManagerImpl()
    
    @Published var authState = AuthState.signedOut
    
    var token: String? {
        GIDSignIn.sharedInstance.currentUser?.idToken?.tokenString
    }
    
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

enum AuthState {
    case signedOut
    case signedIn
}
