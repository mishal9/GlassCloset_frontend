//
//  PurpleGradientBackground.swift
//  GlassCloset
//
//  Created by Mishal on 5/10/25.
//

import SwiftUI

/// A beautiful purple-blue gradient background as shown in the reference image
struct PurpleGradientBackground: View {
    // Optional properties to customize the gradient
    var startColor: Color = Color(red: 0.75, green: 0.75, blue: 0.95) // Light purple-blue
    var endColor: Color = Color(red: 0.85, green: 0.85, blue: 1.0)    // Lighter purple-blue
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [startColor, endColor]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

/// A modifier to apply the purple gradient background to any view
struct PurpleGradientBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            PurpleGradientBackground()
            content
        }
    }
}

/// Extension to make it easy to apply the background
extension View {
    func withPurpleGradientBackground() -> some View {
        self.modifier(PurpleGradientBackgroundModifier())
    }
}

struct PurpleGradientBackground_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Purple Gradient Background")
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(
                    GlassBackground()
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                )
                .clipShape(RoundedRectangle(cornerRadius: GlassDesignSystem.Radius.lg, style: .continuous))
        }
        .withPurpleGradientBackground()
    }
}
