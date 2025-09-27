//
//  RestClientError.swift
//  JiraSwift
//
//  Created for JiraSwift REST API operations.
//

import Foundation

public enum RestClientError: LocalizedError {
    case networkError(Error)
    case httpError(Int, String?)
    case noData
    case deserialization(Error)
    case invalidURL
    case unauthorized
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let code, let message):
            if let message = message {
                return "HTTP \(code): \(message)"
            }
            return "HTTP error: \(code)"
        case .noData:
            return "No data received from server"
        case .deserialization(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL"
        case .unauthorized:
            return "Authentication failed - check your credentials"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
    
    public var localizedDescription: String {
        return errorDescription ?? "Unknown error"
    }
}