//
//  ProfileScreen.swift
//  GlassCloset
//
//  Created by Cascade on 4/27/25.
//

import SwiftUI

struct ProfileScreen: View {
    @StateObject private var authService = AuthService.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: GlassDesignSystem.Spacing.lg) {
                    // Profile header
                    VStack(spacing: GlassDesignSystem.Spacing.md) {
                        // Profile image
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(GlassDesignSystem.Colors.primary(in: colorScheme))
                        
                        // User info
                        VStack(spacing: GlassDesignSystem.Spacing.xs) {
                            Text(authService.currentUser?.username ?? "User")
                                .font(GlassDesignSystem.Typography.title2)
                                .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                            
                            Text(authService.currentUser?.email ?? "user@example.com")
                                .font(GlassDesignSystem.Typography.bodyMedium)
                                .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                        }
                    }
                    .padding(GlassDesignSystem.Spacing.lg)
                    .glassCard(cornerRadius: GlassDesignSystem.Radius.lg)
                    
                    // Settings sections
                    VStack(spacing: GlassDesignSystem.Spacing.md) {
                        // Account settings
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Account")
                                .font(GlassDesignSystem.Typography.title3)
                                .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                                .padding(.horizontal, GlassDesignSystem.Spacing.md)
                                .padding(.vertical, GlassDesignSystem.Spacing.sm)
                            
                            settingRow(icon: "person.fill", title: "Edit Profile")
                            settingRow(icon: "lock.fill", title: "Change Password")
                            settingRow(icon: "bell.fill", title: "Notifications")
                        }
                        .glassCard(cornerRadius: GlassDesignSystem.Radius.md)
                        
                        // App settings
                        VStack(alignment: .leading, spacing: 0) {
                            Text("App Settings")
                                .font(GlassDesignSystem.Typography.title3)
                                .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                                .padding(.horizontal, GlassDesignSystem.Spacing.md)
                                .padding(.vertical, GlassDesignSystem.Spacing.sm)
                            
                            settingRow(icon: "moon.fill", title: "Dark Mode")
                            settingRow(icon: "hand.raised.fill", title: "Privacy")
                            settingRow(icon: "questionmark.circle.fill", title: "Help & Support")
                        }
                        .glassCard(cornerRadius: GlassDesignSystem.Radius.md)
                        
                        // Logout button
                        Button(action: {
                            authService.logout()
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square.fill")
                                Text("Log Out")
                                    .font(GlassDesignSystem.Typography.bodyMedium)
                            }
                            .foregroundColor(GlassDesignSystem.Colors.error)
                            .padding(GlassDesignSystem.Spacing.md)
                            .frame(maxWidth: .infinity)
                            .glassBackground(cornerRadius: GlassDesignSystem.Radius.md)
                        }
                    }
                }
                .padding(GlassDesignSystem.Spacing.md)
            }
            .navigationTitle("Profile")
        }
    }
    
    // Helper function to create consistent setting rows
    private func settingRow(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24, height: 24)
                .foregroundColor(GlassDesignSystem.Colors.primary(in: colorScheme))
            
            Text(title)
                .font(GlassDesignSystem.Typography.bodyMedium)
                .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(GlassDesignSystem.Colors.textTertiary(in: colorScheme))
        }
        .padding(GlassDesignSystem.Spacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle tap action for each setting
        }
    }
}

#Preview {
    ProfileScreen()
}
