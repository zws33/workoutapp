//
//  SignInView.swift
//  workoutapp
//
//  Created by Zach Smith on 4/16/25.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    let auth: any AuthManager = AuthManagerImpl.shared
    @State private var signInError: String? = nil
    @State private var isSigningIn = false

    var body: some View {
        VStack(spacing: 20) {
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

            if isSigningIn {
                ProgressView("Signing in...")
                    .padding(.top, 20)
            }

            Button(action: {
                Task {
                    signInError = nil
                    isSigningIn = true
                    do {
                        try await auth.signInWithGoogle()
                    } catch {
                        signInError = error.localizedDescription
                    }
                    isSigningIn = false
                }
            }) {
                HStack {
                    Image(systemName: "globe")
                    Text("Sign In with Google")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}
