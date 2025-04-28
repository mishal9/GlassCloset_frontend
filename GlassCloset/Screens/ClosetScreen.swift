//
//  ClosetScreen.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import SwiftUI

struct ClosetScreen: View {
    @StateObject private var authService = AuthService.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    
    let filterOptions = ["All", "Tops", "Bottoms", "Dresses", "Outerwear", "Shoes", "Accessories"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(GlassDesignSystem.Colors.textTertiary(in: colorScheme))
                    
                    TextField("Search your closet", text: $searchText)
                        .font(GlassDesignSystem.Typography.bodyMedium)
                }
                .padding(GlassDesignSystem.Spacing.md)
                .glassBackground(cornerRadius: GlassDesignSystem.Radius.md)
                .padding(.horizontal, GlassDesignSystem.Spacing.md)
                .padding(.top, GlassDesignSystem.Spacing.md)
                
                // Filter options
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: GlassDesignSystem.Spacing.sm) {
                        ForEach(filterOptions, id: \.self) { filter in
                            Button(action: {
                                selectedFilter = filter
                            }) {
                                Text(filter)
                                    .font(GlassDesignSystem.Typography.bodyMedium)
                                    .padding(.horizontal, GlassDesignSystem.Spacing.md)
                                    .padding(.vertical, GlassDesignSystem.Spacing.sm)
                                    .background(
                                        selectedFilter == filter ?
                                        GlassDesignSystem.Colors.primary(in: colorScheme) :
                                        GlassDesignSystem.Colors.background(in: colorScheme)
                                    )
                                    .foregroundColor(
                                        selectedFilter == filter ?
                                        Color.white :
                                        GlassDesignSystem.Colors.textPrimary(in: colorScheme)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, GlassDesignSystem.Spacing.md)
                    .padding(.vertical, GlassDesignSystem.Spacing.md)
                }
                
                // Empty state
                ScrollView {
                    VStack(spacing: GlassDesignSystem.Spacing.lg) {
                        Spacer()
                        
                        Image(systemName: "tshirt")
                            .font(.system(size: 64))
                            .foregroundColor(GlassDesignSystem.Colors.textTertiary(in: colorScheme))
                            .padding()
                        
                        Text("Your closet is empty")
                            .font(GlassDesignSystem.Typography.title2)
                            .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                        
                        Text("Scan your clothing items to add them to your virtual closet")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                            .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, GlassDesignSystem.Spacing.lg)
                        
                        NavigationLink(destination: ScanClothingScreen()) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Scan Clothing")
                                    .font(GlassDesignSystem.Typography.bodyMedium)
                            }
                            .padding(GlassDesignSystem.Spacing.md)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryGlassButtonStyle())
                        .padding(.horizontal, GlassDesignSystem.Spacing.md)
                        .padding(.top, GlassDesignSystem.Spacing.md)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(GlassDesignSystem.Spacing.md)
                }
            }
            .navigationTitle("My Closet")
        }
    }
}

#Preview {
    ClosetScreen()
}
