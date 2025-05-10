//
//  MainTabView.swift
//  GlassCloset
//
//  Created by Cascade on 4/27/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var authService = AuthService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeScreen()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // Scan Clothing Tab
            ScanClothingScreen()
                .tabItem {
                    Label("Scan", systemImage: "camera.fill")
                }
                .tag(1)
            
            // Closet Tab
            ClosetScreen()
                .tabItem {
                    Label("Closet", systemImage: "tshirt.fill")
                }
                .tag(2)
            
            // Profile Tab
            ProfileScreen()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(Color(red: 0.4, green: 0.2, blue: 0.6)) // Purple accent color to match the app's design
    }
}

#Preview {
    MainTabView()
}
