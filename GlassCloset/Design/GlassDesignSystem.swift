//
//  GlassDesignSystem.swift
//  GlassCloset
//
//  Created by Mishal on 4/27/25.
//

import SwiftUI

/// GlassDesignSystem: A comprehensive design system for glassmorphic/visionOS style UI
/// that works with both light and dark mode
struct GlassDesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Base colors that adapt to light/dark mode
        static func background(in colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "121212") : Color(hex: "F8F9FA")
        }
        
        static func foreground(in colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "1E1E1E") : Color.white
        }
        
        // Glass effect colors
        static let glassLight = Color.white.opacity(0.15)
        static let glassDark = Color.black.opacity(0.1)
        
        // Accent colors
        static func primary(in colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "7795F8") : Color(hex: "5E72E4")
        }
        
        static func secondary(in colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "A0AEC0") : Color(hex: "8392AB")
        }
        
        static func accent(in colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "0BC5EA") : Color(hex: "11CDEF")
        }
        
        // Status colors
        static let success = Color.green
        static let warning = Color.yellow
        static let error = Color.red
        static let info = Color.blue
        
        // Text colors
        static func textPrimary(in colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "F7FAFC") : Color(hex: "2D3748")
        }
        
        static func textSecondary(in colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "E2E8F0") : Color(hex: "4A5568")
        }
        
        static func textTertiary(in colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "A0AEC0") : Color(hex: "718096")
        }
        
        // Dynamic glass tint based on color scheme
        static func glassTint(in colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? glassDark : glassLight
        }
        
        // Convenience static properties for common use
        static var primary: Color {
            Color(hex: "5E72E4")
        }
        
        static var secondary: Color {
            Color(hex: "8392AB")
        }
        
        static var accent: Color {
            Color(hex: "11CDEF")
        }
    }
    
    // MARK: - Typography
    struct Typography {
        // Title styles
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        
        // Body styles
        static let bodyLarge = Font.system(size: 17, weight: .regular, design: .rounded)
        static let bodyMedium = Font.system(size: 15, weight: .regular, design: .rounded)
        static let bodySmall = Font.system(size: 13, weight: .regular, design: .rounded)
        
        // Caption styles
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        static let captionBold = Font.system(size: 12, weight: .semibold, design: .rounded)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Radius
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 28
        static let circular: CGFloat = 999
    }
    
    // MARK: - Shadows
    struct Shadows {
        // Shadow values for different intensities
        static func subtleColor(colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.05)
        }
        
        static func mediumColor(colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? .white.opacity(0.08) : .black.opacity(0.08)
        }
        
        static func strongColor(colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? .white.opacity(0.12) : .black.opacity(0.12)
        }
    }
}

// MARK: - View Modifiers
extension View {
    /// Applies a glassmorphic background style to a view
    func glassBackground(cornerRadius: CGFloat = GlassDesignSystem.Radius.lg) -> some View {
        self.modifier(GlassBackgroundModifier(cornerRadius: cornerRadius))
    }
    
    /// Applies a glassmorphic card style to a view
    func glassCard(cornerRadius: CGFloat = GlassDesignSystem.Radius.lg) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
    
    /// Applies a glassmorphic button style
    func glassButton(cornerRadius: CGFloat = GlassDesignSystem.Radius.md) -> some View {
        self.modifier(GlassButtonModifier(cornerRadius: cornerRadius))
    }
    
    /// Applies a floating effect to a view
    func floatingEffect(intensity: CGFloat = 1.0) -> some View {
        self.modifier(FloatingEffectModifier(intensity: intensity))
    }
    
    /// Applies a subtle shadow that adapts to color scheme
    func subtleShadow() -> some View {
        self.modifier(AdaptiveShadowModifier(intensity: .subtle))
    }
    
    /// Applies a medium shadow that adapts to color scheme
    func mediumShadow() -> some View {
        self.modifier(AdaptiveShadowModifier(intensity: .medium))
    }
    
    /// Applies a strong shadow that adapts to color scheme
    func strongShadow() -> some View {
        self.modifier(AdaptiveShadowModifier(intensity: .strong))
    }
}

// MARK: - Custom Modifiers


/// Adaptive shadow modifier that automatically adapts to the current color scheme
struct AdaptiveShadowModifier: ViewModifier {
    enum Intensity {
        case subtle, medium, strong
    }
    
    let intensity: Intensity
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        switch intensity {
        case .subtle:
            content.shadow(
                color: colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.05),
                radius: 5,
                x: 0,
                y: 2
            )
        case .medium:
            content.shadow(
                color: colorScheme == .dark ? .white.opacity(0.08) : .black.opacity(0.08),
                radius: 10,
                x: 0,
                y: 4
            )
        case .strong:
            content.shadow(
                color: colorScheme == .dark ? .white.opacity(0.12) : .black.opacity(0.12),
                radius: 15,
                x: 0,
                y: 6
            )
        }
    }
}

/// Glass background modifier
struct GlassBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Base blur
                    Color.clear
                        .background(.ultraThinMaterial)
                    
                    // Tint overlay
                    GlassDesignSystem.Colors.glassTint(in: colorScheme)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            .shadow(
                color: colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.1),
                radius: 10,
                x: 0,
                y: 4
            )
    }
}

/// Glass card modifier
struct GlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(GlassDesignSystem.Spacing.md)
            .background(
                ZStack {
                    // Base blur
                    Color.clear
                        .background(.ultraThinMaterial)
                    
                    // Tint overlay
                    GlassDesignSystem.Colors.glassTint(in: colorScheme)
                    
                    // Border
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            .linearGradient(
                                colors: [
                                    .white.opacity(colorScheme == .dark ? 0.2 : 0.5),
                                    .clear,
                                    .white.opacity(colorScheme == .dark ? 0.1 : 0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            .modifier(AdaptiveShadowModifier(intensity: .medium))
    }
}

/// Glass button modifier
struct GlassButtonModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, GlassDesignSystem.Spacing.sm)
            .padding(.horizontal, GlassDesignSystem.Spacing.md)
            .background(
                ZStack {
                    // Base blur
                    Color.clear
                        .background(.ultraThinMaterial)
                    
                    // Tint overlay with opacity based on enabled state
                    GlassDesignSystem.Colors.glassTint(in: colorScheme)
                        .opacity(isEnabled ? 1.0 : 0.5)
                    
                    // Border
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            .linearGradient(
                                colors: [
                                    .white.opacity(colorScheme == .dark ? 0.3 : 0.6),
                                    .clear,
                                    .white.opacity(colorScheme == .dark ? 0.1 : 0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            .modifier(AdaptiveShadowModifier(intensity: .subtle))
            .opacity(isEnabled ? 1.0 : 0.7)
    }
}

/// Floating effect modifier
struct FloatingEffectModifier: ViewModifier {
    let intensity: CGFloat
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: isAnimating ? -3 * intensity : 0)
            .animation(
                Animation.easeInOut(duration: 2.5)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Button Styles
/// Glass button style
struct GlassButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .glassButton()
    }
}

/// Primary glass button style
struct PrimaryGlassButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.vertical, GlassDesignSystem.Spacing.sm)
            .padding(.horizontal, GlassDesignSystem.Spacing.md)
            .background(
                ZStack {
                    // Base color
                    GlassDesignSystem.Colors.primary(in: colorScheme)
                        .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
                    
                    // Overlay for glass effect
                    Color.white.opacity(0.15)
                    
                    // Border
                    RoundedRectangle(cornerRadius: GlassDesignSystem.Radius.md, style: .continuous)
                        .stroke(
                            .linearGradient(
                                colors: [
                                    .white.opacity(0.5),
                                    .clear,
                                    .white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: GlassDesignSystem.Radius.md, style: .continuous))
            )
            .shadow(
                color: GlassDesignSystem.Colors.primary(in: colorScheme).opacity(0.3),
                radius: 8,
                x: 0,
                y: 3
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.7)
    }
}

// MARK: - Reusable Components
/// Glass card view
struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = GlassDesignSystem.Radius.lg
    
    init(cornerRadius: CGFloat = GlassDesignSystem.Radius.lg, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .glassCard(cornerRadius: cornerRadius)
    }
}

/// Glass container view
struct GlassContainer<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = GlassDesignSystem.Radius.lg
    
    init(cornerRadius: CGFloat = GlassDesignSystem.Radius.lg, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .glassBackground(cornerRadius: cornerRadius)
    }
}
