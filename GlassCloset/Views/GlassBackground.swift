//
//  GlassBackground.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import SwiftUI

/// A reusable glass background view that adapts to light and dark mode
/// This component implements the glassmorphic/visionOS style
struct GlassBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = GlassDesignSystem.Radius.lg
    var intensity: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Base blur material
            Color.clear
                .background(.ultraThinMaterial)
            
            // Tint overlay that adapts to color scheme
            GlassDesignSystem.Colors.glassTint(in: colorScheme)
                .opacity(intensity)
            
            // Subtle gradient overlay for depth
            LinearGradient(
                colors: [
                    .white.opacity(colorScheme == .dark ? 0.05 : 0.1),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Subtle border for enhanced depth perception
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    .linearGradient(
                        colors: [
                            .white.opacity(colorScheme == .dark ? 0.2 : 0.5),
                            .clear,
                            .white.opacity(colorScheme == .dark ? 0.05 : 0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        }
    }
}

/// A preview provider for GlassBackground
struct GlassBackground_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light mode preview
            VStack(spacing: 20) {
                Text("Glass Background")
                    .font(GlassDesignSystem.Typography.title2)
                    .padding()
                    .background(
                        GlassBackground()
                            .shadow(
                                color: .black.opacity(0.1),
                                radius: 10,
                                x: 0,
                                y: 4
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: GlassDesignSystem.Radius.lg, style: .continuous))
                
                Text("Different Intensity")
                    .font(GlassDesignSystem.Typography.title3)
                    .padding()
                    .background(
                        GlassBackground(intensity: 0.5)
                            .shadow(
                                color: .black.opacity(0.1),
                                radius: 10,
                                x: 0,
                                y: 4
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: GlassDesignSystem.Radius.lg, style: .continuous))
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Light Mode")
            
            // Dark mode preview
            VStack(spacing: 20) {
                Text("Glass Background")
                    .font(GlassDesignSystem.Typography.title2)
                    .padding()
                    .background(
                        GlassBackground()
                            .shadow(
                                color: .white.opacity(0.1),
                                radius: 10,
                                x: 0,
                                y: 4
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: GlassDesignSystem.Radius.lg, style: .continuous))
                
                Text("Different Intensity")
                    .font(GlassDesignSystem.Typography.title3)
                    .padding()
                    .background(
                        GlassBackground(intensity: 0.5)
                            .shadow(
                                color: .white.opacity(0.1),
                                radius: 10,
                                x: 0,
                                y: 4
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: GlassDesignSystem.Radius.lg, style: .continuous))
            }
            .padding()
            .background(Color.black)
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
