import SwiftUI

struct ScanClothingScreen: View {
    @StateObject private var viewModel = ScanClothingViewModel()
    @State private var capturedImage: UIImage? = nil
    @State private var showCamera = false  // Define the state for showing camera
    @State private var showAttributes = true
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Show processing, captured image or prompt
                if viewModel.isProcessing {
                    ProgressView("Processing clothing...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(height: 300)
                        .glassBackground(cornerRadius: GlassDesignSystem.Radius.lg)
                } else if let savedImage = viewModel.savedImage {
                    // The image will be shown as captured
                    Image(uiImage: savedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: GlassDesignSystem.Radius.lg, style: .continuous))
                        .glassCard(cornerRadius: GlassDesignSystem.Radius.lg)
                } else {
                    Text("Capture a clothing item!")
                        .font(GlassDesignSystem.Typography.title3)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .glassBackground(cornerRadius: GlassDesignSystem.Radius.lg)
                }
                
                // API Analysis results
                if !viewModel.clothingAttributes.isEmpty {
                    VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.sm) {
                        HStack {
                            Text("Clothing Analysis")
                                .font(GlassDesignSystem.Typography.title3)
                                .foregroundColor(GlassDesignSystem.Colors.textPrimary(in: colorScheme))
                            
                            Spacer()
                            
                            Button(action: {
                                showAttributes.toggle()
                            }) {
                                Image(systemName: showAttributes ? "chevron.up" : "chevron.down")
                                    .foregroundColor(GlassDesignSystem.Colors.primary(in: colorScheme))
                            }
                        }
                        
                        if showAttributes {
                            // Color chips for main colors
                            if !viewModel.clothingAttributes.mainColors.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Colors")
                                        .font(GlassDesignSystem.Typography.captionBold)
                                        .foregroundColor(GlassDesignSystem.Colors.textSecondary(in: colorScheme))
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(viewModel.clothingAttributes.mainColors, id: \.self) { color in
                                                ColorChip(colorName: color, attributes: viewModel.clothingAttributes)
                                            }
                                            
                                            // Add secondary colors if available
                                            ForEach(viewModel.clothingAttributes.secondaryColors.filter { $0 != "Not detected" }, id: \.self) { color in
                                                ColorChip(colorName: color, attributes: viewModel.clothingAttributes)
                                                    .opacity(0.7) // Slightly dimmed to indicate secondary
                                            }
                                        }
                                    }
                                }
                                .padding(.top, GlassDesignSystem.Spacing.xs)
                            }
                            
                            // Attribute grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                // Type
                                if !viewModel.clothingAttributes.garmentType.isEmpty && viewModel.clothingAttributes.garmentType != "Not detected" {
                                    AttributeRow(icon: "tshirt", title: "Type", value: viewModel.clothingAttributes.garmentType.capitalized)
                                }
                                
                                // Material
                                if !viewModel.clothingAttributes.material.isEmpty && viewModel.clothingAttributes.material != "Not detected" {
                                    AttributeRow(icon: "square.grid.3x3", title: "Material", value: viewModel.clothingAttributes.material.capitalized)
                                }
                                
                                // Pattern
                                if !viewModel.clothingAttributes.pattern.isEmpty && viewModel.clothingAttributes.pattern != "Not detected" {
                                    AttributeRow(icon: "square.on.circle", title: "Pattern", value: viewModel.clothingAttributes.pattern.capitalized)
                                }
                                
                                // Style
                                if !viewModel.clothingAttributes.style.isEmpty && viewModel.clothingAttributes.style != "Not detected" {
                                    AttributeRow(icon: "person.crop.square", title: "Style", value: viewModel.clothingAttributes.style.capitalized)
                                }
                                
                                // Season
                                if !viewModel.clothingAttributes.season.isEmpty && viewModel.clothingAttributes.season != "Not detected" {
                                    AttributeRow(icon: "sun.max", title: "Season", value: viewModel.clothingAttributes.season.capitalized)
                                }
                                
                                // Occasion
                                if !viewModel.clothingAttributes.occasion.isEmpty && viewModel.clothingAttributes.occasion != "Not detected" {
                                    AttributeRow(icon: "calendar", title: "Occasion", value: viewModel.clothingAttributes.occasion.capitalized)
                                }
                                
                                // Fit
                                if !viewModel.clothingAttributes.fit.isEmpty && viewModel.clothingAttributes.fit != "Not detected" {
                                    AttributeRow(icon: "ruler", title: "Fit", value: viewModel.clothingAttributes.fit.capitalized)
                                }
                                
                                // Brand
                                if !viewModel.clothingAttributes.brand.isEmpty && viewModel.clothingAttributes.brand != "Not detected" {
                                    AttributeRow(icon: "tag", title: "Brand", value: viewModel.clothingAttributes.brand)
                                }
                            }
                            .padding(.top, GlassDesignSystem.Spacing.sm)
                        }
                    }
                    .padding(GlassDesignSystem.Spacing.md)
                    .glassCard(cornerRadius: GlassDesignSystem.Radius.lg)
                    .padding(.horizontal, GlassDesignSystem.Spacing.md)
                }
                
                // API Error message if any
                if !viewModel.apiError.isEmpty {
                    Text("Error: \(viewModel.apiError)")
                        .font(GlassDesignSystem.Typography.bodyMedium)
                        .foregroundColor(GlassDesignSystem.Colors.error)
                        .padding(GlassDesignSystem.Spacing.md)
                        .glassBackground(cornerRadius: GlassDesignSystem.Radius.md)
                        .padding(.horizontal, GlassDesignSystem.Spacing.md)
                }
                
                // Loading indicator for API analysis
                if viewModel.isAnalyzingWithAPI {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        
                        Text("Analyzing clothing attributes...")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                            .foregroundColor(GlassDesignSystem.Colors.textTertiary(in: colorScheme))
                            .padding(.leading, GlassDesignSystem.Spacing.sm)
                    }
                    .padding(GlassDesignSystem.Spacing.md)
                    .glassBackground(cornerRadius: GlassDesignSystem.Radius.md)
                    .padding(.horizontal, GlassDesignSystem.Spacing.md)
                }
                
                // Capture button
                Button(action: {
                    captureClothing()  // Show camera when button is pressed
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Capture Clothing")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                    }
                    .padding(GlassDesignSystem.Spacing.md)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryGlassButtonStyle())
                .padding(.horizontal, GlassDesignSystem.Spacing.md)
                
                // Recapture button (only show if we have attributes)
                if !viewModel.clothingAttributes.isEmpty {
                    Button(action: {
                        captureClothing()
                    }) {
                        Text("Recapture")
                            .font(GlassDesignSystem.Typography.bodyMedium)
                            .padding(GlassDesignSystem.Spacing.md)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(GlassButtonStyle())
                    .padding(.horizontal, GlassDesignSystem.Spacing.md)
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showCamera, onDismiss: {
            if let captured = capturedImage {
                viewModel.processCapturedImage(captured)
            }
        }) {
            ImagePicker(selectedImage: $capturedImage)
        }
    }

    private func captureClothing() {
        // Trigger the camera to open
        showCamera = true
    }
}
