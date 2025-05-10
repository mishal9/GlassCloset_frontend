//
//  HomeScreen.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import SwiftUI

struct HomeScreen: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var weatherViewModel = WeatherViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Explicit gradient definition with darker colors
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.6, green: 0.6, blue: 0.85), // Darker purple-blue
                        Color(red: 0.7, green: 0.7, blue: 0.95)  // Medium purple-blue
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: GlassDesignSystem.Spacing.lg) {
                        // Welcome section
                        VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.sm) {
                            Text("Welcome to Glass Closet")
                                .font(GlassDesignSystem.Typography.title1)
                                .foregroundColor(.white)
                            
                            Text("Your AI-powered wardrobe assistant")
                                .font(GlassDesignSystem.Typography.bodyMedium)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(GlassDesignSystem.Spacing.md)
                        .grayCard(cornerRadius: GlassDesignSystem.Radius.lg)
                        
                        // Weather section
                        VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.md) {
                            Text("Today's Weather")
                                .font(GlassDesignSystem.Typography.title3)
                                .foregroundColor(.white)
                                .padding(.horizontal, GlassDesignSystem.Spacing.md)
                            
                            WeatherCardView(viewModel: weatherViewModel)
                                .padding(.bottom, GlassDesignSystem.Spacing.xs)
                        }
                        
                        // Quick actions
                        VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.md) {
                            Text("Quick Actions")
                                .font(GlassDesignSystem.Typography.title3)
                                .foregroundColor(.white)
                            
                            HStack(spacing: GlassDesignSystem.Spacing.md) {
                                // Scan action
                                NavigationLink(destination: ScanClothingScreen()) {
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 40, height: 40)
                                            
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.85))
                                        }
                                        
                                        Text("Scan Item")
                                            .font(GlassDesignSystem.Typography.bodyMedium)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(GlassDesignSystem.Spacing.md)
                                    .grayCard(cornerRadius: GlassDesignSystem.Radius.md)
                                }
                                
                                // Closet action
                                NavigationLink(destination: ClosetScreen()) {
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 40, height: 40)
                                            
                                            Image(systemName: "tshirt.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.85))
                                        }
                                        
                                        Text("My Closet")
                                            .font(GlassDesignSystem.Typography.bodyMedium)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(GlassDesignSystem.Spacing.md)
                                    .grayCard(cornerRadius: GlassDesignSystem.Radius.md)
                                }
                            }
                        }
                        .padding(GlassDesignSystem.Spacing.md)
                        
                        // Weather-based outfit recommendations
                        if let weatherData = weatherViewModel.weatherData {
                            VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.md) {
                                Text("Weather-Based Outfit Suggestions")
                                    .font(GlassDesignSystem.Typography.title3)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.sm) {
                                    ForEach(weatherViewModel.getClothingRecommendations().prefix(3), id: \.self) { recommendation in
                                        HStack(spacing: GlassDesignSystem.Spacing.sm) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                            
                                            Text(recommendation)
                                                .font(GlassDesignSystem.Typography.bodyMedium)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    Button(action: {
                                        // This will be handled by the WeatherCardView's outfit tips button
                                    }) {
                                        Text("See more suggestions")
                                            .font(GlassDesignSystem.Typography.bodyMedium)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.top, GlassDesignSystem.Spacing.xs)
                                }
                                .padding(GlassDesignSystem.Spacing.md)
                                .grayCard(cornerRadius: GlassDesignSystem.Radius.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(GlassDesignSystem.Spacing.md)
                        }
                        
                        // Recent items section (placeholder)
                        VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.md) {
                            Text("Recent Items")
                                .font(GlassDesignSystem.Typography.title3)
                                .foregroundColor(.white)
                            
                            Text("You haven't added any items yet. Scan your first clothing item to get started!")
                                .font(GlassDesignSystem.Typography.bodyMedium)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.leading)
                                .padding(GlassDesignSystem.Spacing.md)
                                .grayCard(cornerRadius: GlassDesignSystem.Radius.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(GlassDesignSystem.Spacing.md)
                    }
                    .padding(GlassDesignSystem.Spacing.md)
                }
                .navigationTitle("Home")
                .onAppear {
                    // Request weather update when the screen appears
                    weatherViewModel.refreshWeather()
                }
            }
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
