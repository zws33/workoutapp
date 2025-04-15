//
//  Errors.swift
//  workoutapp
//
//  Created by Zach Smith on 4/15/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case noData
    case decodingFailed(Error)
}

enum AuthError : Error {
    case invalidCredentials
    case expiredToken
    case missingToken
    case unknown
}
