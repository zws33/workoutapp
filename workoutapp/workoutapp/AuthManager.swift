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
    func signInWithEmailAndPassword(email: String, password: String) async throws
    func createUser(email: String, password: String) async throws
    func signOut() throws
}

class AuthManagerImpl: ObservableObject, AuthManager {
    static let shared = AuthManagerImpl()
    
    @Published var authState = AuthState.signedOut
    
    func getIDToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in."])
        }
        return try await user.getIDToken(forcingRefresh: true)
    }
    
    init() {

    }
    
    func signInWithEmailAndPassword(email: String, password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            await MainActor.run {
                self.authState = .signedIn
            }
        } catch {
            print(error)
        }

    }
    
    func createUser(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        self.authState = .signedOut
    }
}

enum AuthState {
    case signedOut
    case signedIn
}
