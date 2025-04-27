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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "cloud.sun.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.yellow, Color.white)
                    .font(.system(size: 30))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(temperature)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text(feelsLike)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text(location)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding()
        }
        .background(
            GlassBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .white.opacity(0.1), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct GlassBackground: View {
    var body: some View {
        Color.white.opacity(0.1)
            .background(.ultraThinMaterial)
            .blur(radius: 10)
    }
}

struct WeatherCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            WeatherCardView()
        }
    }
}
