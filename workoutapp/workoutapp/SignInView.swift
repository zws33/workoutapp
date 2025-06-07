//
//  SignInView.swift
//  workoutapp
//
//  Created by Zach Smith on 4/16/25.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSigningIn = false
    @State private var signInError: String? = nil
    
    let auth = AuthManagerImpl.shared

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.walk")
                .font(.system(size: 70))
                .foregroundColor(.blue)

            Text("Workout Tracker")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Password", text: $password)
                .textContentType(.password)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)

            if let error = signInError {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }

            if isSigningIn {
                ProgressView("Signing in...")
                    .padding(.top, 20)
            }
            Button(
                action: {
                    Task {
                        signInError = nil
                        isSigningIn = true
                        do {
                            try await auth.signInWithEmailAndPassword(email: "zach.smith33@gmail.com", password: "password")
                        } catch {
                            signInError = error.localizedDescription
                        }
                        isSigningIn = false
                    }
                }
            ) {
                HStack {
                    Image(systemName: "person.fill.checkmark")
                    Text("Sign In")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.top, 20)
                
            Button(action: {
                Task {
                    signInError = nil
                    isSigningIn = true
                    do {
                        try await auth
                            .createUser(email: email, password: password)
                        // handle post-account-creation logic if needed
                    } catch {
                        signInError = error.localizedDescription
                    }
                    isSigningIn = false
                }
            }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Create Account")
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(email.isEmpty || password.isEmpty)
            .padding(.top, 10)
            
        }
        .padding()
    }
}

