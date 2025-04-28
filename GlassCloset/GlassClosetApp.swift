//
//  GlassClosetApp.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import SwiftUI
import SwiftData

@main
struct GlassClosetApp: App {
    @StateObject private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                // Main app content with tab navigation
                MainTabView()
            } else {
                // Authentication flow
                LoginScreen()
            }
        }
    }
}
