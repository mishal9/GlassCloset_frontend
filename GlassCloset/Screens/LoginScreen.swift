//
//  LoginScreen.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import SwiftUI

struct LoginScreen: View {
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showSignup = false
    @State private var isLoggingIn = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: GlassDesignSystem.Spacing.lg) {
                // Logo/Header
                VStack(spacing: GlassDesignSystem.Spacing.sm) {
                    Text("Glass Closet")
                        .font(GlassDesignSystem.Typography.largeTitle)
                        .foregroundColor(GlassDesignSystem.Colors.primary(in: colorScheme))
                    
                    Text("Your AI-powered wardrobe assistant")
                        .font(GlassDesignSystem.Typography.bodyMedium)
                        .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                
                // Form fields
                VStack(spacing: GlassDesignSystem.Spacing.md) {
                    // Email field
                    VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.xs) {
                        Text("Email")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                            .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                        
                        TextField("Enter your email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(GlassDesignSystem.Spacing.md)
                            .glassBackground(cornerRadius: GlassDesignSystem.Radius.md)
                    }
                    
                    // Password field
                    VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.xs) {
                        Text("Password")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                            .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                        
                        SecureField("Enter your password", text: $password)
                            .padding(GlassDesignSystem.Spacing.md)
                            .glassBackground(cornerRadius: GlassDesignSystem.Radius.md)
                    }
                }
                .padding(.horizontal, GlassDesignSystem.Spacing.md)
                
                // Error message if any
                if let error = authService.error {
                    Text(error)
                        .font(GlassDesignSystem.Typography.bodySmall)
                        .foregroundColor(GlassDesignSystem.Colors.error)
                        .padding(.horizontal, GlassDesignSystem.Spacing.md)
                }
                
                // Login button
                Button(action: {
                    Task {
                        isLoggingIn = true
                        let success = await authService.login(email: email, password: password)
                        isLoggingIn = false
                    }
                }) {
                    if isLoggingIn {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(Color.white)
                    } else {
                        Text("Log In")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(GlassDesignSystem.Spacing.md)
                .buttonStyle(PrimaryGlassButtonStyle())
                .padding(.horizontal, GlassDesignSystem.Spacing.md)
                .disabled(email.isEmpty || password.isEmpty || isLoggingIn)
                
                // Sign up navigation
                HStack(spacing: GlassDesignSystem.Spacing.xs) {
                    Text("Don't have an account?")
                        .font(GlassDesignSystem.Typography.bodyMedium)
                        .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                    
                    NavigationLink(destination: SignupScreen()) {
                        Text("Sign Up")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                            .foregroundColor(GlassDesignSystem.Colors.primary(in: colorScheme))
                    }
                }
                .padding(.top, GlassDesignSystem.Spacing.sm)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LoginScreen()
}
