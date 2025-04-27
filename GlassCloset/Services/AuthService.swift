//
//  AuthService.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import Foundation
import Combine
import SwiftUI

class AuthService: ObservableObject {
    // Published properties to track authentication state
    @Published var currentUser: User? = nil
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    // API base URL from Constants
    private let baseURL = Constants.API.baseURL
    
    // Singleton instance
    static let shared = AuthService()
    
    private init() {
        // Check for saved token on init
        if let token = UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken) {
            self.isAuthenticated = true
            // Optionally fetch user profile here
        }
    }
    
    // Login function
    func login(email: String, password: String) async -> Bool {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        // Create URL with query parameters for login
        var components = URLComponents(string: "\(baseURL)\(Constants.API.login)")
        components?.queryItems = [
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "password", value: password)
        ]
        
        guard let url = components?.url else {
            await MainActor.run {
                self.error = "Invalid URL"
                self.isLoading = false
            }
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    self.error = "Invalid response"
                    self.isLoading = false
                }
                return false
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                let loginResponse = try decoder.decode(LoginResponse.self, from: data)
                
                // Save token to UserDefaults
                UserDefaults.standard.set(loginResponse.access_token, forKey: Constants.UserDefaults.accessToken)
                
                // Create a mock user for now - in a real app, you'd fetch user details
                let user = User(id: UUID().uuidString, email: email, username: email.components(separatedBy: "@").first ?? "user")
                
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                    self.isLoading = false
                }
                return true
            } else {
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                await MainActor.run {
                    self.error = errorResponse?.detail ?? "Login failed"
                    self.isLoading = false
                }
                return false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            return false
        }
    }
    
    // Signup function
    func signup(email: String, password: String) async -> Bool {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        // Create URL with query parameters for signup
        var components = URLComponents(string: "\(baseURL)\(Constants.API.signup)")
        components?.queryItems = [
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "password", value: password)
        ]
        
        guard let url = components?.url else {
            await MainActor.run {
                self.error = "Invalid URL"
                self.isLoading = false
            }
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    self.error = "Invalid response"
                    self.isLoading = false
                }
                return false
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                let signupResponse = try decoder.decode(SignupResponse.self, from: data)
                
                await MainActor.run {
                    self.isLoading = false
                }
                return true
            } else {
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                await MainActor.run {
                    self.error = errorResponse?.detail ?? "Signup failed"
                    self.isLoading = false
                }
                return false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            return false
        }
    }
    
    // Logout function
    func logout() {
        // Clear token
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.accessToken)
        
        // Update state
        currentUser = nil
        isAuthenticated = false
    }
    
    // Get auth token
    func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken)
    }
}

// Response models
struct LoginResponse: Codable {
    let message: String
    let access_token: String
}

struct SignupResponse: Codable {
    let message: String
    let user_id: String
}

struct ErrorResponse: Codable {
    let detail: String
}
