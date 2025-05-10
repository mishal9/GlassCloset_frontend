//
//  SignupScreen.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import SwiftUI

struct SignupScreen: View {
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSigningUp = false
    @State private var showLoginScreen = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var passwordsMatch: Bool {
        return password == confirmPassword
    }
    
    var formIsValid: Bool {
        return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && passwordsMatch && password.count >= 6
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: GlassDesignSystem.Spacing.lg) {
                // Header
                VStack(spacing: GlassDesignSystem.Spacing.sm) {
                    Text("Create Account")
                        .font(GlassDesignSystem.Typography.title1)
                        .foregroundColor(GlassDesignSystem.Colors.primary(in: colorScheme))
                    
                    Text("Join Glass Closet to organize your wardrobe")
                        .font(GlassDesignSystem.Typography.bodyMedium)
                        .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
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
                        
                        SecureField("Enter your password (min 6 characters)", text: $password)
                            .padding(GlassDesignSystem.Spacing.md)
                            .glassBackground(cornerRadius: GlassDesignSystem.Radius.md)
                        
                        if !password.isEmpty && password.count < 6 {
                            Text("Password must be at least 6 characters")
                                .font(GlassDesignSystem.Typography.bodySmall)
                                .foregroundColor(GlassDesignSystem.Colors.error)
                        }
                    }
                    
                    // Confirm Password field
                    VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.xs) {
                        Text("Confirm Password")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                            .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                        
                        SecureField("Confirm your password", text: $confirmPassword)
                            .padding(GlassDesignSystem.Spacing.md)
                            .glassBackground(cornerRadius: GlassDesignSystem.Radius.md)
                        
                        if !confirmPassword.isEmpty && !passwordsMatch {
                            Text("Passwords do not match")
                                .font(GlassDesignSystem.Typography.bodySmall)
                                .foregroundColor(GlassDesignSystem.Colors.error)
                        }
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
                
                // Sign Up button
                Button(action: {
                    Task {
                        isSigningUp = true
                        let success = await authService.signup(email: email, password: password)
                        isSigningUp = false
                        
                        if success {
                            // Navigate back to login screen
                            dismiss()
                        }
                    }
                }) {
                    if isSigningUp {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(Color.white)
                    } else {
                        Text("Sign Up")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(GlassDesignSystem.Spacing.md)
                .buttonStyle(PrimaryGlassButtonStyle())
                .padding(.horizontal, GlassDesignSystem.Spacing.md)
                .disabled(!formIsValid || isSigningUp)
                
                // Login navigation
                HStack(spacing: GlassDesignSystem.Spacing.xs) {
                    Text("Already have an account?")
                        .font(GlassDesignSystem.Typography.bodyMedium)
                        .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Log In")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                            .foregroundColor(GlassDesignSystem.Colors.primary(in: colorScheme))
                    }
                }
                .padding(.top, GlassDesignSystem.Spacing.sm)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SignupScreen()
    }
}
