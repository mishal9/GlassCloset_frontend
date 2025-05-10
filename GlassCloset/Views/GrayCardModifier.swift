//
//  GrayCardModifier.swift
//  GlassCloset
//
//  Created by Mishal on 5/10/25.
//

import SwiftUI

/// A consistent gray card background modifier for all cards in the app
struct GrayCardModifier: ViewModifier {
    var cornerRadius: CGFloat = GlassDesignSystem.Radius.lg
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.4)) // Lighter gray semi-transparent background
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
    }
}

/// Extension to make it easy to apply the gray card background
extension View {
    func grayCard(cornerRadius: CGFloat = GlassDesignSystem.Radius.lg) -> some View {
        self.modifier(GrayCardModifier(cornerRadius: cornerRadius))
    }
}
