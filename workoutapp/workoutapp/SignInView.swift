//
//  SignInView.swift
//  workoutapp
//
//  Created by Zach Smith on 4/16/25.
//


import SwiftUI
import GoogleSignIn

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthManager
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
