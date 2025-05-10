//
//  ClosetScreen.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import SwiftUI

struct ClosetScreen: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var viewModel = ClosetViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    let filterOptions = ["All", "Tops", "Bottoms", "Dresses", "Outerwear", "Shoes", "Accessories"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(GlassDesignSystem.Colors.textTertiary(in: colorScheme))
                    
                    TextField("Search your closet", text: $viewModel.searchText)
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
                                viewModel.selectedFilter = filter
                            }) {
                                Text(filter)
                                    .font(GlassDesignSystem.Typography.bodyMedium)
                                    .padding(.horizontal, GlassDesignSystem.Spacing.md)
                                    .padding(.vertical, GlassDesignSystem.Spacing.sm)
                                    .background(
                                        viewModel.selectedFilter == filter ?
                                        GlassDesignSystem.Colors.primary(in: colorScheme) :
                                        GlassDesignSystem.Colors.background(in: colorScheme)
                                    )
                                    .foregroundColor(
                                        viewModel.selectedFilter == filter ?
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
                
                if viewModel.isLoading {
                    // Loading state
                    VStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("Loading your closet...")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                            .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    // Error state
                    VStack(spacing: GlassDesignSystem.Spacing.lg) {
                        Spacer()
                        
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 64))
                            .foregroundColor(Color.orange)
                            .padding()
                        
                        Text("Something went wrong")
                            .font(GlassDesignSystem.Typography.title2)
                            .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                        
                        Text(errorMessage)
                            .font(GlassDesignSystem.Typography.bodyMedium)
                            .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, GlassDesignSystem.Spacing.lg)
                        
                        Button(action: {
                            viewModel.fetchUserClothingItems()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Try Again")
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
                } else if viewModel.filteredItems.isEmpty {
                    if viewModel.clothingItems.isEmpty {
                        // Empty closet state
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
                    } else {
                        // No results for filter/search
                        VStack(spacing: GlassDesignSystem.Spacing.lg) {
                            Spacer()
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 64))
                                .foregroundColor(GlassDesignSystem.Colors.textTertiary(in: colorScheme))
                                .padding()
                            
                            Text("No matching items")
                                .font(GlassDesignSystem.Typography.title2)
                                .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                            
                            Text("Try adjusting your search or filter")
                                .font(GlassDesignSystem.Typography.bodyMedium)
                                .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, GlassDesignSystem.Spacing.lg)
                            
                            Button(action: {
                                viewModel.searchText = ""
                                viewModel.selectedFilter = "All"
                            }) {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("Clear Filters")
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
                } else {
                    // Display clothing items in a grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: GlassDesignSystem.Spacing.md) {
                            ForEach(viewModel.sortedByDateAdded(viewModel.filteredItems)) { item in
                                ItemView(item: item)
                                    .environmentObject(viewModel)
                            }
                        }
                        .padding(GlassDesignSystem.Spacing.md)
                    }
                    .refreshable {
                        viewModel.fetchUserClothingItems()
                    }
                }
            }
            }
            .navigationTitle("My Closet")
            .onAppear {
                viewModel.fetchUserClothingItems()
            }
        }
    }


#Preview {
    ClosetScreen()
}
