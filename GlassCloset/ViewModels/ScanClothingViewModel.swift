import SwiftUI
import Foundation
import UIKit

class ScanClothingViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var isAnalyzingWithAPI = false
    @Published var savedImage: UIImage? = nil
    @Published var clothingAttributes: ClothingAttributes = ClothingAttributes()
    @Published var apiError: String = ""
    @Published var needsAuthentication = false
    
    // Reference to auth service
    private let authService = AuthService.shared
    
    // Track the original captured image for reference
    private var originalCapturedImage: UIImage? = nil
    
    init() {
        // No initialization needed
    }
    
    // Process the captured image - only uses API analysis
    func processCapturedImage(_ capturedImage: UIImage) {
        print("📸 Processing captured image of size: \(capturedImage.size)")
        
        // Save original image for reference
        self.originalCapturedImage = capturedImage
        
        // Fix the image orientation
        let orientedImage = fixOrientation(capturedImage)
        
        // Start processing
        DispatchQueue.main.async(execute: DispatchWorkItem(block: {
            self.isProcessing = true
            self.clothingAttributes = ClothingAttributes()
            self.apiError = ""
            // Show the original image immediately
            self.savedImage = orientedImage
        }))
        
        // Send the image to the backend API for analysis
        analyzeImageWithBackendAPI(orientedImage)
    }
    
    // Fix image orientation to ensure proper processing
    private func fixOrientation(_ image: UIImage) -> UIImage {
        // If the orientation is already up, return the image as is
        if image.imageOrientation == .up {
            return image
        }
        
        // Create a new CGContext and draw the image with the correct orientation
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        print("🔄 Fixed image orientation from \(image.imageOrientation.rawValue) to .up")
        return normalizedImage
    }
    
    // MARK: - Backend API Integration
    
    /// Analyze the image using the backend API
    private func analyzeImageWithBackendAPI(_ image: UIImage) {
        // Ensure user is authenticated before making API request
        guard authService.isAuthenticated, authService.getAuthToken() != nil else {
            DispatchQueue.main.async(execute: DispatchWorkItem(block: {
                self.apiError = "Please log in to analyze clothing items"
                self.isProcessing = false
                self.needsAuthentication = true
            }))
            return
        }
        
        DispatchQueue.main.async(execute: DispatchWorkItem(block: {
            self.isAnalyzingWithAPI = true
        }))
        
        APIService.shared.analyzeImage(image) { result in
            DispatchQueue.main.async(execute: DispatchWorkItem(block: {
                self.isAnalyzingWithAPI = false
                self.isProcessing = false
                
                switch result {
                case .success(let attributes):
                    print("✅ API Analysis successful: \(attributes)")
                    // Set the clothing attributes directly
                    self.clothingAttributes = attributes
                case .failure(let error):
                    print("❌ API Analysis failed: \(error.localizedDescription)")
                    self.apiError = error.localizedDescription
                    
                    // Check if the error is authentication-related
                    if let apiError = error as? APIError, apiError == .authenticationRequired {
                        self.needsAuthentication = true
                    }
                }
            }))
        }
    }
    
    // MARK: - Helper Methods
    
    // Helper methods can be added here as needed
}
