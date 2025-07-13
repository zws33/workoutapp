//
//  AppLogger.swift
//  workoutapp
//
//  Created by Zach Smith on 6/14/25.
//

import Foundation
import os.log

/// Centralized logging utility for the entire app
enum AppLogger {
    
    // MARK: - Category Loggers
    static let general = Logger(subsystem: subsystem, category: "General")
    static let networking = Logger(subsystem: subsystem, category: "Networking")
    static let coreData = Logger(subsystem: subsystem, category: "CoreData")
    static let auth = Logger(subsystem: subsystem, category: "Authentication")
    static let ui = Logger(subsystem: subsystem, category: "UI")
    
    // MARK: - Private
    private static let subsystem = "com.workoutapp"
    
    // MARK: - Convenience Methods
    
    /// Log general app events
    static func info(_ message: String, category: LogCategory = .general) {
        logger(for: category).info("\(message)")
    }
    
    /// Log HTTP request lifecycle events
    static func httpRequest(
        _ event: HTTPRequestEvent,
        requestId: String,
        url: String? = nil,
        statusCode: Int? = nil,
        duration: TimeInterval? = nil,
        error: Error? = nil
    ) {
        var message = "[\(requestId)] \(event.description)"
        
        if let url = url {
            message += " - \(url)"
        }
        
        if let statusCode = statusCode {
            message += " - Status: \(statusCode)"
        }
        
        if let duration = duration {
            message += " - Duration: \(String(format: "%.3f", duration))s"
        }
        
        if let error = error {
            networking.error("\(message) - Error: \(error.localizedDescription)")
        } else {
            networking.info("\(message)")
        }
    }
    
    /// Log debugging information
    static func debug(_ message: String, category: LogCategory = .general) {
        logger(for: category).debug("\(message)")
    }
    
    /// Log errors
    static func error(_ message: String, error: Error? = nil, category: LogCategory = .general) {
        if let error = error {
            logger(for: category).error("\(message): \(error.localizedDescription)")
        } else {
            logger(for: category).error("\(message)")
        }
    }
    
    /// Log warnings
    static func warning(_ message: String, category: LogCategory = .general) {
        logger(for: category).warning("\(message)")
    }
    
    /// Log critical issues
    static func critical(_ message: String, category: LogCategory = .general) {
        logger(for: category).critical("\(message)")
    }
    
    // MARK: - Private Helpers
    
    private static func logger(for category: LogCategory) -> Logger {
        switch category {
        case .general: return general
        case .networking: return networking
        case .coreData: return coreData
        case .auth: return auth
        case .ui: return ui
        }
    }
}

// MARK: - Log Categories

enum LogCategory {
    case general
    case networking
    case coreData
    case auth
    case ui
}

// MARK: - HTTP Request Events

enum HTTPRequestEvent {
    case requestStart
    case authTokenRetrieved
    case networkCallStarted
    case responseReceived
    case responseValidated
    case decodingStarted
    case decodingCompleted
    case requestCompleted
    case requestFailed
    
    var description: String {
        switch self {
        case .requestStart: return "Request started"
        case .authTokenRetrieved: return "Auth token retrieved"
        case .networkCallStarted: return "Network call started"
        case .responseReceived: return "Response received"
        case .responseValidated: return "Response validated"
        case .decodingStarted: return "Decoding started"
        case .decodingCompleted: return "Decoding completed"
        case .requestCompleted: return "Request completed"
        case .requestFailed: return "Request failed"
        }
    }
}