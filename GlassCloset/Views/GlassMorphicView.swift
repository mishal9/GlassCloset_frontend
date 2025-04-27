//
//  GlassMorphicView.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import SwiftUI
import SwiftData

struct GlassmorphicCardView: View {
    var body: some View {
        VStack {
            Text("Glassmorphic Effect")
                .font(.title)
                .foregroundColor(.white)
                .bold()
                .padding()
        }
        .frame(width: 300, height: 200)
        .background(
            ZStack {
                // Using Color with opacity to give the background a frosted effect
                Color.white.opacity(0.1) // Light translucent background
                    .blur(radius: 10)  // Apply blur for the frosted glass effect
                    .cornerRadius(20) // Corner radius to give it rounded edges
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1) // Light border
                    )
            }
        )
        .cornerRadius(20)
        .shadow(radius: 10)  // Shadow to give a sense of depth
        .padding()
    }
}

struct GlassmorphicCardView_Previews: PreviewProvider {
    static var previews: some View {
        GlassmorphicCardView()
    }
}
