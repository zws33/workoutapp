//
//  AuthManager.swift
//  workoutapp
//
//  Created by Zach Smith on 4/16/25.
//


import SwiftUI
import GoogleSignIn
import FirebaseAuth

protocol AuthManager {
    var authState: AuthState { get }
    func getIDToken() async throws -> String
    func signInWithGoogle() async throws
    func signOut() throws
}

class AuthManagerImpl: ObservableObject, AuthManager {
    static let shared = AuthManagerImpl()
    
    @Published var authState = AuthState.signedOut
    
    private lazy var firebaseAuth = Auth.auth()
    
    // Store the listener handle so we can remove it later
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
    }
    
    func listenForAuthStateChanges() {
        // Store the handle returned by Firebase
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                self?.authState = user != nil ? .signedIn : .signedOut
            }
        }
    }

    // Clean up when AuthManager is deallocated
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signInWithGoogle() async throws {
        guard let presentingViewController = await getRootViewController() else {
            throw AuthError.noPresentingViewController
        }
         
        guard let clientID = firebaseAuth.app?.options.clientID else {
            throw AuthError.noClientID
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw AuthError.noIDToken
        }
        
        let accessToken = user.accessToken.tokenString
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let _ = try await firebaseAuth.signIn(with: credential)
        await MainActor.run {
            authState = .signedIn
        }
    }
    
    func getIDToken() async throws -> String {
        guard let user = firebaseAuth.currentUser else {
            throw AuthError.notAuthenticated
        }
        
        return try await user.getIDToken()
    }
    
    private func getRootViewController() async -> UIViewController? {
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first else {
            return nil
        }
         
        return await window.rootViewController
    }
    
    func signOut() throws {
        try firebaseAuth.signOut()
        GIDSignIn.sharedInstance.signOut()
    }
}

enum AuthState {
    case signedOut
    case signedIn
}
