//
//  APIService.swift
//  GlassCloset
//
//  Created by Cascade on 4/27/25.
//

import Foundation
import UIKit
import Network

class APIService {
    
    // Base URL for the backend API from Constants
    private let baseURL = Constants.API.baseURL
    
    // Singleton instance
    static let shared = APIService()
    
    // Network path monitor to check connectivity
    private let networkMonitor = NWPathMonitor()
    private var isConnected = false
    
    // Custom URLSession with better timeout handling
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 60 // Increased timeout for image analysis
        config.timeoutIntervalForRequest = 60 // Increased request timeout
        config.waitsForConnectivity = true // Wait for connectivity
        return URLSession(configuration: config)
    }()
    
    private init() {
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            print("🌐 Network status: \(path.status == .satisfied ? "Connected" : "Disconnected")")
            
            // Log more detailed information about the path
            if path.status == .satisfied {
                print("🌐 Network connected")
                print("🌐 Is expensive: \(path.isExpensive)")
                print("🌐 Supports DNS: \(path.supportsDNS)")
                print("🌐 Supports IPv4: \(path.supportsIPv4)")
                print("🌐 Supports IPv6: \(path.supportsIPv6)")
            } else {
                print("🌐 Network unavailable")
                if #available(iOS 15.0, *) {
                    print("🌐 Network unavailable reason: \(path.unsatisfiedReason)")
                }
            }
        }
        networkMonitor.start(queue: queue)
    }
    
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
    func analyzeImage(_ image: UIImage, completion: @escaping (Result<ClothingAttributes, Error>) -> Void) {
        tryAnalyzeImage(image, baseURL: baseURL) { result in
            completion(result)
        }
    }
    
    /// Helper method to try analyzing an image with a specific base URL
    /// - Parameters:
    ///   - image: The UIImage to analyze
    ///   - baseURL: The base URL to use
    ///   - completion: Callback with the analysis result or error
    private func tryAnalyzeImage(_ image: UIImage, baseURL: String, completion: @escaping (Result<ClothingAttributes, Error>) -> Void) {
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
        
        // Check network connectivity first
        guard isConnected else {
            print("⚠️ No network connection available")
            completion(.failure(APIError.noNetworkConnection))
            return
        }
        
        // Create and start the task with our custom session
        let task = self.session.dataTask(with: request) { data, response, error in
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
                // Try to parse as an AnalysisResponse
                let responseObject = try JSONDecoder().decode(AnalysisResponse.self, from: data)
                
                // Extract the attributes from the response
                var attributes = responseObject.attributes
                
                // Add the ID and image URL to the attributes for convenience
                attributes.id = responseObject.clothingItemId
                attributes.imageUrl = responseObject.imageUrl
                
                // Return the attributes
                completion(.success(attributes))
                
                // Log success
                print("✅ Successfully parsed clothing attributes: \(attributes)")
                print("🖼️ Image URL: \(responseObject.imageUrl)")
                print("🔑 Item ID: \(responseObject.clothingItemId)")
                
                // Log the raw analysis string for debugging
                print("📝 Raw analysis: \(responseObject.analysis)")
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
    
    // MARK: - Clothing Items
    
    /// Fetches all clothing items for the current logged-in user
    /// - Parameter completion: Callback with the array of clothing items or error
    func fetchUserClothingItems(completion: @escaping (Result<[ClothingItem], Error>) -> Void) {
        // Endpoint for clothing items from Constants
        let endpoint = Constants.API.clothingItems
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Get auth token and ensure it's included in the request
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("⚠️ No auth token available for API request")
            completion(.failure(APIError.authenticationRequired))
            return
        }
        
        // Check network connectivity first
        guard isConnected else {
            print("⚠️ No network connection available")
            completion(.failure(APIError.noNetworkConnection))
            return
        }
        
        // Create and start the task
        let task = session.dataTask(with: request) { data, response, error in
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
                // Print the raw JSON for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }
                
                // Create a decoder with custom date decoding strategy
                let decoder = JSONDecoder()
                
                // Try to parse using the wrapper model
                let response = try decoder.decode(ClothingItemResponse.self, from: data)
                completion(.success(response.clothingItems))
                print("✅ Successfully fetched \(response.clothingItems.count) clothing items")
            } catch let decodingError as DecodingError {
                // More detailed error for decoding issues
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Key not found: \(key), context: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch: \(type), context: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found: \(type), context: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error: \(decodingError)")
                }
                
                // Try to get the raw response as string for debugging
                let responseString = String(data: data, encoding: .utf8) ?? "Could not decode response"
                print("Raw response: \(responseString)")
                
                // Try to decode as a dictionary for more debugging info
                if let jsonObject = try? JSONSerialization.jsonObject(with: data) {
                    print("JSON structure: \(jsonObject)")
                }
                
                completion(.failure(APIError.decodingFailed))
            } catch {
                print("Other error during decoding: \(error)")
                let responseString = String(data: data, encoding: .utf8) ?? "Could not decode response"
                print("Raw response: \(responseString)")
                completion(.failure(APIError.decodingFailed))
            }
        }
        
        task.resume()
    }
    
    /// Deletes a clothing item with the specified ID
    /// - Parameters:
    ///   - itemId: The ID of the clothing item to delete
    ///   - completion: Callback with success or error
    func deleteClothingItem(itemId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Endpoint for deleting a clothing item
        let endpoint = Constants.API.clothingItems + "/\(itemId)"
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Get auth token and ensure it's included in the request
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("⚠️ No auth token available for API request")
            completion(.failure(APIError.authenticationRequired))
            return
        }
        
        // Check network connectivity first
        guard isConnected else {
            print("⚠️ No network connection available")
            completion(.failure(APIError.noNetworkConnection))
            return
        }
        
        // Create and start the task
        let task = session.dataTask(with: request) { data, response, error in
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
                // Try to parse the response
                let deleteResponse = try JSONDecoder().decode(DeleteResponse.self, from: data)
                if deleteResponse.success {
                    print("✅ Successfully deleted clothing item: \(itemId)")
                    print("📝 Message: \(deleteResponse.message)")
                    completion(.success(true))
                } else {
                    print("❌ Failed to delete clothing item: \(itemId)")
                    print("📝 Message: \(deleteResponse.message)")
                    completion(.failure(APIError.operationFailed(message: deleteResponse.message)))
                }
            } catch {
                print("Error decoding delete response: \(error)")
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
    let attributes: ClothingAttributes
    let clothingItemId: String
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case analysis
        case attributes
        case clothingItemId = "clothing_item_id"
        case imageUrl = "image_url"
    }
}

// Response for delete operations
struct DeleteResponse: Codable {
    let success: Bool
    let message: String
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
    case noNetworkConnection
    case operationFailed(message: String)
    
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
        case .noNetworkConnection:
            return "No network connection available"
        case .operationFailed(let message):
            return "Operation failed: \(message)"
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
            (.authenticationRequired, .authenticationRequired),
            (.noNetworkConnection, .noNetworkConnection):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.operationFailed(let lhsMessage), .operationFailed(let rhsMessage)):
            return lhsMessage == rhsMessage
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
