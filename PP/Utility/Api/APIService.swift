//
//  APIService.swift
//  PP
//
//  Created by Ly Kimheng on 26/5/26.
//

import Foundation

class APIService {
    static let shared = APIService()        // ← singleton, call anywhere
    
    private let baseURL = "http:/192.168.2.17:8888/PP"
    
    // MARK: - Register
    func register(name: String, email: String, password: String, location: String) async -> Result<UserResponse, APIError> {
        guard let url = URL(string: "\(baseURL)/register.php") else {
            return .failure(.invalidURL)
        }
        
        let body: [String: String] = [
            "name": name,
            "email": email,
            "password": password,
            "location": location
        ]
        
        return await sendRequest(url: url, body: body)
    }
    
    // MARK: - Login
    func login(email: String, password: String) async -> Result<UserResponse, APIError> {
        guard let url = URL(string: "\(baseURL)/login.php") else {
            return .failure(.invalidURL)
        }
        
        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        
        return await sendRequest(url: url, body: body)
    }
    // MARK: - Forget Password
    func forgotPassword(email: String, newPassword: String) async -> Result<UserResponse, APIError> {
        guard let url = URL(string: "\(baseURL)/forgot_password.php") else {
            return .failure(.invalidURL)
        }

        let body: [String: String] = [
            "email": email,
            "newPassword": newPassword
        ]

        return await sendRequest(url: url, body: body)
    }
    
    // MARK: - Shared Request Handler
    private func sendRequest(url: URL, body: [String: String]) async -> Result<UserResponse, APIError> {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(UserResponse.self, from: data)
            
            if response.success {
                return .success(response)
            } else {
                return .failure(.serverError(response.message))
            }
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
}

// MARK: - Response Models
struct UserResponse: Codable {
    let success: Bool
    let message: String
    let user: UserData?
}

struct UserData: Codable {
    let id: Int
    let name: String
    let email: String
    let location: String
}

// MARK: - Error Types
enum APIError: Error {
    case invalidURL
    case networkError(String)
    case serverError(String)
    
    var message: String {
        switch self {
        case .invalidURL:               return "Invalid URL."
        case .networkError(let msg):    return "Network error: \(msg)"
        case .serverError(let msg):     return msg
        }
    }
}
