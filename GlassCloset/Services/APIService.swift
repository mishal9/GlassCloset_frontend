//
//  APIService.swift
//  GlassCloset
//
//  Created by Cascade on 4/27/25.
//

import Foundation
import UIKit

class APIService {
    
    // Base URL for the backend API from Constants
    private let baseURL = Constants.API.baseURL
    
    // Singleton instance
    static let shared = APIService()
    
    private init() {}
    
    // MARK: - Authentication
    
    // Get the authentication token from AuthService
    private func getAuthToken() -> String? {
        let token = AuthService.shared.getAuthToken()
        print("🔑 Using auth token: \(token ?? "nil")")
        return token
    }
    
    // MARK: - Image Analysis
    
    /// Analyzes an image using the backend API
    /// - Parameters:
    ///   - image: The UIImage to analyze
    ///   - completion: Callback with the analysis result or error
    func analyzeImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // Endpoint for image analysis from Constants
        let endpoint = Constants.API.analyzeImage
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        // Convert image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(APIError.imageConversionFailed))
            return
        }
        
        // Create multipart form data request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Get auth token and ensure it's included in the request
        if let token = getAuthToken() {
            // For debugging purposes, log a shortened version of the token
            let shortToken = token.count > 20 ? "\(token.prefix(10))...\(token.suffix(10))" : token
            print("🔒 Added auth token to request: Bearer \(shortToken)")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("⚠️ No auth token available for API request")
            completion(.failure(APIError.authenticationRequired))
            return
        }
        
        // Generate boundary string
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create body
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close the boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Set the request body
        request.httpBody = body
        
        // Create and start the task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check for HTTP status code
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            // Check for successful status code
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            // Check for data
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            // Parse the response
            do {
                let responseObject = try JSONDecoder().decode(AnalysisResponse.self, from: data)
                completion(.success(responseObject.analysis))
            } catch {
                print("JSON Decoding Error: \(error)")
                // Try to get the raw response as string for debugging
                let responseString = String(data: data, encoding: .utf8) ?? "Could not decode response"
                print("Raw response: \(responseString)")
                completion(.failure(APIError.decodingFailed))
            }
        }
        
        task.resume()
    }
}

// MARK: - Response Models

struct AnalysisResponse: Codable {
    let analysis: String
}

// MARK: - Error Types

enum APIError: Error, LocalizedError, Equatable {
    case invalidURL
    case imageConversionFailed
    case invalidResponse
    case serverError(statusCode: Int)
    case noData
    case decodingFailed
    case authenticationRequired
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .imageConversionFailed:
            return "Failed to convert image to data"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .noData:
            return "No data received from server"
        case .decodingFailed:
            return "Failed to decode response"
        case .authenticationRequired:
            return "Authentication required - please log in"
        }
    }
    
    // Implement Equatable conformance
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.imageConversionFailed, .imageConversionFailed),
             (.invalidResponse, .invalidResponse),
             (.noData, .noData),
             (.decodingFailed, .decodingFailed),
             (.authenticationRequired, .authenticationRequired):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}

// MARK: - Data Extensions

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
