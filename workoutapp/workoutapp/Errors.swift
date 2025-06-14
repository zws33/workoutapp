//
//  Errors.swift
//  workoutapp
//
//  Created by Zach Smith on 4/15/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL(String)
    case requestFailed(Error)
    case transportError(Error)
    case invalidResponse
    case noData
    case decodingFailed(Error)
}

enum AuthError: LocalizedError {
    case noPresentingViewController
    case noClientID
    case noIDToken
    case notAuthenticated
    case googleSignInCancelled
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noPresentingViewController:
            return "No presenting view controller available"
        case .noClientID:
            return "No Google client ID configured"
        case .noIDToken:
            return "Failed to get ID token from Google"
        case .notAuthenticated:
            return "User is not authenticated"
        case .googleSignInCancelled:
            return "Google Sign-In was cancelled"
        case .unknown(let error):
            return "Authentication error: \(error.localizedDescription)"
        }
    }
}

enum CoreDataError: Error {
    case noDataFound
    case invalidData(String)
}
