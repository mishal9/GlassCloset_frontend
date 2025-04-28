//
//  Constants.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import Foundation

struct Constants {
    struct API {
        static let baseURL = "http://192.168.1.159" // "https://glasscloset-backend.onrender.com"
        
        // Endpoints
        static let login = "/login"
        static let signup = "/signup"
        static let analyzeImage = "/analyze-image"
        static let health = "/health"
    }
    
    struct UserDefaults {
        static let accessToken = "accessToken"
    }
}
