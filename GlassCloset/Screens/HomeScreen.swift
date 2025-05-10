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
            ScrollView {
                VStack(spacing: GlassDesignSystem.Spacing.lg) {
                    // Welcome section
                    VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.sm) {
                        Text("Welcome to Glass Closet")
                            .font(GlassDesignSystem.Typography.title1)
                            .foregroundColor(GlassDesignSystem.Colors.primary(in: colorScheme))
                        
                        Text("Your AI-powered wardrobe assistant")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                            .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(GlassDesignSystem.Spacing.md)
                    .glassCard(cornerRadius: GlassDesignSystem.Radius.lg)
                    
                    // Weather section
                    VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.md) {
                        Text("Today's Weather")
                            .font(GlassDesignSystem.Typography.title3)
                            .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                            .padding(.horizontal, GlassDesignSystem.Spacing.md)
                        
                        WeatherCardView(viewModel: weatherViewModel)
                            .padding(.bottom, GlassDesignSystem.Spacing.xs)
                    }
                    
                    // Quick actions
                    VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.md) {
                        Text("Quick Actions")
                            .font(GlassDesignSystem.Typography.title3)
                            .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                        
                        HStack(spacing: GlassDesignSystem.Spacing.md) {
                            // Scan action
                            NavigationLink(destination: ScanClothingScreen()) {
                                VStack {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(GlassDesignSystem.Colors.primary(in: colorScheme))
                                    
                                    Text("Scan Item")
                                        .font(GlassDesignSystem.Typography.bodyMedium)
                                        .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(GlassDesignSystem.Spacing.md)
                                .glassBackground(cornerRadius: GlassDesignSystem.Radius.md)
                            }
                            
                            // Closet action
                            NavigationLink(destination: ClosetScreen()) {
                                VStack {
                                    Image(systemName: "tshirt.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(GlassDesignSystem.Colors.primary(in: colorScheme))
                                    
                                    Text("My Closet")
                                        .font(GlassDesignSystem.Typography.bodyMedium)
                                        .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(GlassDesignSystem.Spacing.md)
                                .glassBackground(cornerRadius: GlassDesignSystem.Radius.md)
                            }
                        }
                    }
                    .padding(GlassDesignSystem.Spacing.md)
                    
                    // Weather-based outfit recommendations
                    if let weatherData = weatherViewModel.weatherData {
                        VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.md) {
                            Text("Weather-Based Outfit Suggestions")
                                .font(GlassDesignSystem.Typography.title3)
                                .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                            
                            VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.sm) {
                                ForEach(weatherViewModel.getClothingRecommendations().prefix(3), id: \.self) { recommendation in
                                    HStack(spacing: GlassDesignSystem.Spacing.sm) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(GlassDesignSystem.Colors.accent)
                                        
                                        Text(recommendation)
                                            .font(GlassDesignSystem.Typography.bodyMedium)
                                            .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                                    }
                                }
                                
                                Button(action: {
                                    // This will be handled by the WeatherCardView's outfit tips button
                                }) {
                                    Text("See more suggestions")
                                        .font(GlassDesignSystem.Typography.bodyMedium)
                                        .foregroundColor(GlassDesignSystem.Colors.primary(in: colorScheme))
                                }
                                .padding(.top, GlassDesignSystem.Spacing.xs)
                            }
                            .padding(GlassDesignSystem.Spacing.md)
                            .glassBackground(cornerRadius: GlassDesignSystem.Radius.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(GlassDesignSystem.Spacing.md)
                    }
                    
                    // Recent items section (placeholder)
                    VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.md) {
                        Text("Recent Items")
                            .font(GlassDesignSystem.Typography.title3)
                            .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                        
                        Text("You haven't added any items yet. Scan your first clothing item to get started!")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                            .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                            .multilineTextAlignment(.leading)
                            .padding(GlassDesignSystem.Spacing.md)
                            .glassBackground(cornerRadius: GlassDesignSystem.Radius.md)
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

#Preview {
    HomeScreen()
}
