//
//  ItemView.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import SwiftUI

struct ItemView: View {
    let item: ClothingItem
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var viewModel: ClosetViewModel
    @State private var showDetails = false
    @State private var showDeleteConfirmation = false
    
    // Computed property to handle null or empty garment type
    private var displayGarmentType: String {
        let garmentType = item.attributes.garmentType
        if garmentType.isEmpty || garmentType == "null" || garmentType == "Not detected" {
            return "Item"
        }
        return garmentType.capitalized
    }
    
    var body: some View {
        Button(action: {
            showDetails.toggle()
        }) {
            // Using contextMenu for long-press delete option
            VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.sm) {
                // Image with color overlay if no image is available
                ZStack {
                    if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 180)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 180)
                                    .clipped()
                            case .failure:
                                colorPlaceholder
                            @unknown default:
                                colorPlaceholder
                            }
                        }
                        .frame(height: 180)
                    } else {
                        colorPlaceholder
                    }
                    
                    // Type label
                    VStack {
                        Spacer()
                        HStack {
                            Text(displayGarmentType)
                                .font(GlassDesignSystem.Typography.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, GlassDesignSystem.Spacing.sm)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(GlassDesignSystem.Radius.sm)
                            Spacer()
                        }
                        .padding(GlassDesignSystem.Spacing.sm)
                    }
                }
                .frame(height: 180)
                .cornerRadius(GlassDesignSystem.Radius.md)
                
                // Basic info
                VStack(alignment: .leading, spacing: 4) {
                    // Main colors
                    if !item.attributes.mainColors.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(item.attributes.mainColors, id: \.self) { color in
                                Circle()
                                    .fill(item.attributes.colorFromString(color))
                                    .frame(width: 12, height: 12)
                            }
                            Text(item.attributes.mainColors.map { $0.capitalized }.joined(separator: ", "))
                                .font(GlassDesignSystem.Typography.caption)
                                .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                        }
                    }
                    
                    // Material and pattern
                    if !item.attributes.material.isEmpty && item.attributes.material != "Not detected" {
                        Text(item.attributes.material.capitalized)
                            .font(GlassDesignSystem.Typography.caption)
                            .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                    }
                    
                    // Style and occasion
                    if !item.attributes.style.isEmpty && item.attributes.style != "Not detected" {
                        Text(item.attributes.style.capitalized + (item.attributes.occasion != "Not detected" ? " • " + item.attributes.occasion.capitalized : ""))
                            .font(GlassDesignSystem.Typography.caption)
                            .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                    }
                }
                .padding(.horizontal, GlassDesignSystem.Spacing.sm)
                .padding(.bottom, GlassDesignSystem.Spacing.sm)
            }
            .background(GlassDesignSystem.Colors.foreground(in: colorScheme))
            .cornerRadius(GlassDesignSystem.Radius.md)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive, action: {
                showDeleteConfirmation = true
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Item", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("Are you sure you want to delete this item? This action cannot be undone.")
        }
        .sheet(isPresented: $showDetails) {
            ItemDetailView(item: item, onDelete: {
                deleteItem()
            })
            .environmentObject(viewModel)
        }
    }
    
    // Function to handle item deletion
    private func deleteItem() {
        viewModel.deleteClothingItem(itemId: item.id) { success in
            if success {
                // Item was deleted successfully
                // The view will be updated automatically through the ViewModel's published properties
            }
        }
    }
    
    // Color placeholder based on the item's primary color
    private var colorPlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(item.attributes.primaryColor)
                .frame(height: 180)
            
            if item.attributes.secondaryColor != .clear {
                Circle()
                    .fill(item.attributes.secondaryColor)
                    .frame(width: 60, height: 60)
                    .offset(x: 40, y: -30)
                    .opacity(0.7)
            }
            
            Image(systemName: "tshirt.fill")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// Detail view shown when an item is tapped
struct ItemDetailView: View {
    let item: ClothingItem
    var onDelete: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: ClosetViewModel
    @State private var showDeleteConfirmation = false
    
    // Computed property to handle null or empty garment type
    private var displayGarmentType: String {
        let garmentType = item.attributes.garmentType
        if garmentType.isEmpty || garmentType == "null" || garmentType == "Not detected" {
            return "Item"
        }
        return garmentType.capitalized
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.md) {
                    // Image with color overlay if no image is available
                    if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                            case .failure:
                                colorPlaceholder
                                    .frame(height: 300)
                            @unknown default:
                                colorPlaceholder
                                    .frame(height: 300)
                            }
                        }
                    } else {
                        colorPlaceholder
                            .frame(height: 300)
                    }
                    
                    // Attributes section
                    VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.md) {
                        Text("Attributes")
                            .font(GlassDesignSystem.Typography.title3)
                            .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                        
                        // Garment type
                        attributeRow(title: "Type", value: item.attributes.garmentType.capitalized)
                        
                        // Colors
                        if !item.attributes.mainColors.isEmpty {
                            HStack(alignment: .top) {
                                Text("Colors:")
                                    .font(GlassDesignSystem.Typography.bodyMedium)
                                    .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                                    .frame(width: 80, alignment: .leading)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    // Main colors with color dots
                                    ForEach(item.attributes.mainColors, id: \.self) { color in
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(item.attributes.colorFromString(color))
                                                .frame(width: 16, height: 16)
                                            Text(color.capitalized)
                                                .font(GlassDesignSystem.Typography.bodyMedium)
                                                .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                                        }
                                    }
                                    
                                    // Secondary colors with color dots
                                    if !item.attributes.secondaryColors.isEmpty && item.attributes.secondaryColors.first != "Not detected" {
                                        Text("Accent:")
                                            .font(GlassDesignSystem.Typography.caption)
                                            .foregroundColor(GlassDesignSystem.Colors.textTertiary(in: colorScheme))
                                            .padding(.top, 4)
                                        
                                        ForEach(item.attributes.secondaryColors, id: \.self) { color in
                                            HStack(spacing: 8) {
                                                Circle()
                                                    .fill(item.attributes.colorFromString(color))
                                                    .frame(width: 12, height: 12)
                                                Text(color.capitalized)
                                                    .font(GlassDesignSystem.Typography.caption)
                                                    .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Other attributes
                        if !item.attributes.material.isEmpty && item.attributes.material != "Not detected" {
                            attributeRow(title: "Material", value: item.attributes.material.capitalized)
                        }
                        
                        if !item.attributes.pattern.isEmpty && item.attributes.pattern != "Not detected" {
                            attributeRow(title: "Pattern", value: item.attributes.pattern.capitalized)
                        }
                        
                        if !item.attributes.style.isEmpty && item.attributes.style != "Not detected" {
                            attributeRow(title: "Style", value: item.attributes.style.capitalized)
                        }
                        
                        if !item.attributes.season.isEmpty && item.attributes.season != "Not detected" {
                            attributeRow(title: "Season", value: item.attributes.season.capitalized)
                        }
                        
                        if !item.attributes.occasion.isEmpty && item.attributes.occasion != "Not detected" {
                            attributeRow(title: "Occasion", value: item.attributes.occasion.capitalized)
                        }
                        
                        if !item.attributes.fit.isEmpty && item.attributes.fit != "Not detected" {
                            attributeRow(title: "Fit", value: item.attributes.fit.capitalized)
                        }
                        
                        if !item.attributes.brand.isEmpty && item.attributes.brand != "Not detected" {
                            attributeRow(title: "Brand", value: item.attributes.brand)
                        }
                        
                        // Date added
                        attributeRow(title: "Added", value: item.dateAdded.formatted(date: .abbreviated, time: .omitted))
                    }
                    .padding(GlassDesignSystem.Spacing.md)
                    .background(GlassDesignSystem.Colors.foreground(in: colorScheme))
                    .cornerRadius(GlassDesignSystem.Radius.md)
                    .padding(.horizontal, GlassDesignSystem.Spacing.md)
                }
                .padding(.bottom, GlassDesignSystem.Spacing.xl)
            }
            .navigationTitle(displayGarmentType)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(Color.red)
                    }
                }
            }
            .alert("Delete Item", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    onDelete()
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this item? This action cannot be undone.")
            }
        }
    }
    
    // Helper function to create attribute rows
    private func attributeRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text("\(title):")
                .font(GlassDesignSystem.Typography.bodyMedium)
                .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(GlassDesignSystem.Typography.bodyMedium)
                .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                .multilineTextAlignment(.leading)
        }
    }
    
    // Color placeholder based on the item's primary color
    private var colorPlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(item.attributes.primaryColor)
            
            if item.attributes.secondaryColor != .clear {
                Circle()
                    .fill(item.attributes.secondaryColor)
                    .frame(width: 100, height: 100)
                    .offset(x: 60, y: -40)
                    .opacity(0.7)
            }
            
            Image(systemName: "tshirt.fill")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

#Preview {
    ItemView(item: ClothingItem.mockItems.first!)
}

#Preview {
    ItemDetailView(item: ClothingItem.mockItems.first!, onDelete: {})
}
