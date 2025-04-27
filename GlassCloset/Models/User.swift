//
//  User.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let username: String
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    // For demo/testing purposes
    static let mockUser = User(id: UUID().uuidString, email: "test@example.com", username: "testuser")
}
