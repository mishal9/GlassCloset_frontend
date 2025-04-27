//
//  WeatherCardView.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import SwiftUI

struct WeatherCardView: View {
    var temperature: String = "24°C"
    var feelsLike: String = "Feels like 26°"
    var location: String = "London"
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.xs) {
            HStack(alignment: .center, spacing: GlassDesignSystem.Spacing.md) {
                Image(systemName: "cloud.sun.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.yellow, colorScheme == .dark ? Color.white : Color.white)
                    .font(.system(size: 30))
                
                VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.xxs) {
                    Text(temperature)
                        .font(GlassDesignSystem.Typography.title3)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text(feelsLike)
                        .font(GlassDesignSystem.Typography.bodySmall)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7))
                }
                
                Spacer()
                
                Text(location)
                    .font(GlassDesignSystem.Typography.bodyMedium)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .padding(GlassDesignSystem.Spacing.md)
        }
        .glassCard(cornerRadius: GlassDesignSystem.Radius.xl)
        .floatingEffect(intensity: 0.5)
        .padding(.horizontal, GlassDesignSystem.Spacing.md)
    }
    
    // GlassBackground has been moved to its own file and enhanced with the design system
    
    struct WeatherCardView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                // Light mode preview
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                    WeatherCardView()
                }
                .previewDisplayName("Light Mode")
                
                // Dark mode preview
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]),
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                    WeatherCardView()
                }
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
            }
        }
    }
}
