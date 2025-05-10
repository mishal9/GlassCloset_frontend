//
//  Constants.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import Foundation

struct Constants {
    struct API {
        static let baseURL = "https://glasscloset-backend.onrender.com"

        // Endpoints
        static let login = "/login"
        static let signup = "/signup"
        static let analyzeImage = "/analyze-image"
        static let health = "/health"
        static let clothingItems = "/clothing-items"
    }
    
    struct UserDefaults {
        static let accessToken = "accessToken"
    }
}
