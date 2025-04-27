import SwiftUI

struct ScanClothingScreen: View {
    @StateObject private var viewModel = ScanClothingViewModel()
    @State private var capturedImage: UIImage? = nil
    @State private var showCamera = false  // Define the state for showing camera
    @State private var showDetectionDetails = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Show processing, captured image or prompt
                if viewModel.isProcessing {
                    ProgressView("Processing clothing...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(height: 300)
                } else if let savedImage = viewModel.savedImage {
                    // The image will already have bounding boxes drawn on it
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
                
                // Detection results summary
                if !viewModel.detectedObjects.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detection Results")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        ForEach(viewModel.detectedObjects) { object in
                            HStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                
                                Text(object.label)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("\(Int(object.confidence * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 2)
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
                
                // Recapture button (only show if we have results)
                if !viewModel.detectedObjects.isEmpty {
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
            ImagePicker(selectedImage: $capturedImage)  // ImagePicker allows capturing the image
        }
    }

    private func captureClothing() {
        // Trigger the camera to open
        showCamera = true
    }
}

