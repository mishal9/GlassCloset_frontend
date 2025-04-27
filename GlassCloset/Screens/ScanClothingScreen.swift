import SwiftUI

struct ScanClothingScreen: View {
    @StateObject private var viewModel = ScanClothingViewModel()
    @State private var capturedImage: UIImage? = nil
    @State private var showCamera = false  // Define the state for showing camera
    @State private var showAttributes = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Show processing, captured image or prompt
                if viewModel.isProcessing {
                    ProgressView("Processing clothing...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(height: 300)
                } else if let savedImage = viewModel.savedImage {
                    // The image will be shown as captured
                    Image(uiImage: savedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(20)
                } else {
                    Text("Capture a clothing item!")
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                }
                
                // API Analysis results
                if !viewModel.clothingAttributes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Clothing Analysis")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Button(action: {
                                showAttributes.toggle()
                            }) {
                                Image(systemName: showAttributes ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if showAttributes {
                            Text(viewModel.clothingAttributes)
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .padding(.top, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }
                
                // API Error message if any
                if !viewModel.apiError.isEmpty {
                    Text("Error: \(viewModel.apiError)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                // Loading indicator for API analysis
                if viewModel.isAnalyzingWithAPI {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        
                        Text("Analyzing clothing attributes...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Capture button
                Button(action: {
                    captureClothing()  // Show camera when button is pressed
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Capture Clothing")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Recapture button (only show if we have attributes)
                if !viewModel.clothingAttributes.isEmpty {
                    Button(action: {
                        captureClothing()
                    }) {
                        Text("Recapture")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
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
