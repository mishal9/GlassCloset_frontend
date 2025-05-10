//
//  AttributeComponents.swift
//  GlassCloset
//
//  Created by Cascade on 5/9/25.
//

import SwiftUI

// Component to display a color chip with the color name
struct ColorChip: View {
    let colorName: String
    let attributes: ClothingAttributes
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 4) {
            // Color circle
            Circle()
                .fill(attributes.colorFromString(colorName))
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.2), lineWidth: 1)
                )
            
            // Color name
            Text(colorName.capitalized)
                .font(GlassDesignSystem.Typography.caption)
                .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// Component to display an attribute row with icon, title and value
struct AttributeRow: View {
    let icon: String
    let title: String
    let value: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(GlassDesignSystem.Colors.primary(in: colorScheme))
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.7))
                        .overlay(
                            Circle()
                                .stroke(GlassDesignSystem.Colors.primary(in: colorScheme).opacity(0.3), lineWidth: 1)
                        )
                )
            
            VStack(alignment: .leading, spacing: 2) {
                // Attribute title
                Text(title)
                    .font(GlassDesignSystem.Typography.caption)
                    .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                
                // Attribute value
                Text(value)
                    .font(GlassDesignSystem.Typography.bodyMedium)
                    .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.5))
        )
    }
}

// Preview for the components
struct AttributeComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Preview ColorChip
            HStack {
                ColorChip(colorName: "navy", attributes: ClothingAttributes.mock)
                ColorChip(colorName: "white", attributes: ClothingAttributes.mock)
                ColorChip(colorName: "black", attributes: ClothingAttributes.mock)
            }
            
            // Preview AttributeRow
            AttributeRow(icon: "tshirt", title: "Type", value: "Hoodie")
            AttributeRow(icon: "square.grid.3x3", title: "Pattern", value: "Solid")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .previewLayout(.sizeThatFits)
    }
}
