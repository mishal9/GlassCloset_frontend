import SwiftUI
import Vision
import CoreML

class ScanClothingViewModel: ObservableObject {
    private var model: VNCoreMLModel?
    private var visionRequest: VNCoreMLRequest?
    
    @Published var isProcessing = false
    @Published var savedImage: UIImage? = nil
    @Published var detectedObjects: [DetectedObject] = []

    init() {
        // Load the YOLOv3Tiny CoreML model
        loadModel()
    }

    // Load YOLOv3Tiny model and setup Vision request
    private func loadModel() {
        do {
            print("Attempting to load YOLOv3Tiny model...")
            
            // Direct path to the model we found
            let modelPath = "/Users/mishal/Work/GlassCloset/GlassCloset/MLModels/YOLOv3Tiny.mlmodel"
            let modelURL = URL(fileURLWithPath: modelPath)
            
            print("Trying to load model from: \(modelPath)")
            
            // Compile the model if needed
            let compiledModelURL = try MLModel.compileModel(at: modelURL)
            let mlModel = try MLModel(contentsOf: compiledModelURL)
            model = try VNCoreMLModel(for: mlModel)
            
            print("✅ CoreML model loaded successfully from direct path")
            
            // Configure the vision request
            visionRequest = VNCoreMLRequest(model: model!) { [weak self] (request, error) in
                self?.handleDetectionResults(request, error)
            }
            visionRequest?.imageCropAndScaleOption = .scaleFill
            print("✅ Vision request configured with imageCropAndScaleOption: .scaleFill")
        } catch {
            print("❌ ERROR loading CoreML model: \(error)")
            
            // Fallback to the generated class if direct loading fails
            do {
                print("⚠️ Trying fallback method with YOLOv3Tiny class...")
                let config = MLModelConfiguration()
                config.computeUnits = .all
                
                // Try to use the generated Swift class
                if let yoloModel = try? YOLOv3Tiny(configuration: config).model {
                    print("✅ Model loaded via generated class")
                    model = try VNCoreMLModel(for: yoloModel)
                    
                    // Configure the vision request
                    visionRequest = VNCoreMLRequest(model: model!) { [weak self] (request, error) in
                        self?.handleDetectionResults(request, error)
                    }
                    visionRequest?.imageCropAndScaleOption = .scaleFill
                } else {
                    print("❌ Failed to load model via generated class")
                }
            } catch {
                print("❌ FATAL ERROR: All model loading methods failed: \(error)")
            }
        }
    }
    

    // Handle results from the Vision request
    private func handleDetectionResults(_ request: VNRequest, _ error: Error?) {
        print("⏱️ handleDetectionResults called")
        
        // Handle errors
        if let error = error {
            print("❌ Error during request: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isProcessing = false
                self.savedImage = self.originalCapturedImage // Show original image on error
            }
            return
        }
        print("✅ No errors in request")

        // Log all results for debugging
        print("📊 Raw results count: \(request.results?.count ?? 0)")
        if let allResults = request.results {
            for (i, result) in allResults.enumerated() {
                print("  Result \(i): \(result) (type: \(type(of: result)))")
            }
        }
        
        // Get results as VNRecognizedObjectObservation
        guard let results = request.results as? [VNRecognizedObjectObservation] else {
            print("❌ No valid object recognition results - results couldn't be cast to [VNRecognizedObjectObservation]")
            DispatchQueue.main.async {
                self.isProcessing = false
                self.savedImage = self.originalCapturedImage
            }
            return
        }
        
        print("🔍 Number of object recognition results: \(results.count)")

        // If no objects detected
        if results.isEmpty {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.savedImage = self.originalCapturedImage
            }
            print("❌ No objects detected in results array")
            return
        }

        // Filter observations by confidence threshold - use a lower threshold to see more detections
        let confidenceThreshold: Float = 0.1 // Lower this value to detect more objects
        let highConfidenceResults = results.filter { observation in
            guard let topLabel = observation.labels.first else { return false }
            return topLabel.confidence >= confidenceThreshold
        }
        
        // Log detected objects' labels and bounding boxes
        for (index, observation) in highConfidenceResults.enumerated() {
            if let topLabel = observation.labels.first {
                print("Object \(index + 1) label: \(topLabel.identifier) (\(topLabel.confidence)) bounding box: \(observation.boundingBox)")
            }
        }

        // Convert observations to our DetectedObject model for the UI
        let detectedObjects = highConfidenceResults.compactMap { observation -> DetectedObject? in
            guard let topLabel = observation.labels.first else { return nil }
            return DetectedObject(
                label: topLabel.identifier,
                confidence: topLabel.confidence,
                boundingBox: observation.boundingBox
            )
        }
        
        // If no objects detected after filtering
        if highConfidenceResults.isEmpty {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.savedImage = self.originalCapturedImage
                self.detectedObjects = []
            }
            print("No objects detected with confidence above threshold")
            return
        }
        
        // Overlay bounding boxes on the captured image
        guard let capturedImage = self.originalCapturedImage else { return }

        let imageWithBoundingBoxes = overlayBoundingBoxes(image: capturedImage, observations: highConfidenceResults)

        // Save image with bounding boxes and update UI
        DispatchQueue.main.async {
            self.isProcessing = false
            self.savedImage = imageWithBoundingBoxes
            self.detectedObjects = detectedObjects
        }
    }
    
    // No unused methods

    // Overlay bounding boxes on the image
    private func overlayBoundingBoxes(image: UIImage, observations: [VNRecognizedObjectObservation]) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        image.draw(at: .zero)
        
        let context = UIGraphicsGetCurrentContext()
        
        // Draw bounding boxes and labels
        for observation in observations {
            guard let topLabel = observation.labels.first else { continue }
            
            // Convert Vision's normalized coordinates to image coordinates
            // Vision's coordinates are normalized to [0,1] and have origin at bottom-left
            // UIKit's coordinates have origin at top-left
            let boundingBox = observation.boundingBox
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let x = boundingBox.minX * imageWidth
            let y = (1 - boundingBox.maxY) * imageHeight // Flip Y coordinate
            let width = boundingBox.width * imageWidth
            let height = boundingBox.height * imageHeight
            
            let rect = CGRect(x: x, y: y, width: width, height: height)
            
            // Draw bounding box with thicker line and vibrant color
            context?.setStrokeColor(UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0).cgColor)
            context?.setLineWidth(4.0)
            context?.stroke(rect)
            
            // Create label text with confidence
            let confidencePercent = Int(topLabel.confidence * 100)
            let labelText = "\(topLabel.identifier) \(confidencePercent)%"
            
            // Create text attributes with better visibility
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -2.0 // Negative value creates outline effect
            ]
            
            // Determine text size
            let textSize = labelText.size(withAttributes: textAttributes)
            
            // Position label at top of bounding box, ensure it's in bounds
            var labelY = y - textSize.height - 5
            if labelY < 0 { labelY = y + 5 } // If label would be off the top, place below box
            
            // Ensure label doesn't extend past right edge
            var labelX = x
            if x + textSize.width > imageWidth {
                labelX = imageWidth - textSize.width - 5
            }
            
            // Draw a more visible background for the label
            let textRect = CGRect(x: labelX, y: labelY, width: textSize.width + 10, height: textSize.height + 5)
            context?.setFillColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor)
            context?.fill(textRect)
            
            // Draw the label text with position adjusted for padding
            labelText.draw(at: CGPoint(x: labelX + 5, y: labelY + 2.5), withAttributes: textAttributes)
            
            // Debug coordinates
            print("Object: \(labelText) at Normalized: \(boundingBox), Image: \(rect)")
        }

        // Capture the image with overlaid bounding boxes
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage ?? image
    }
    
    // Save the processed image to the local storage (e.g., Photos, App Directory)
    // Track the original captured image for reference
    private var originalCapturedImage: UIImage? = nil
    
    // Process the captured image - updated to save the original image
    func processCapturedImage(_ capturedImage: UIImage) {
        print("📸 Processing captured image of size: \(capturedImage.size)")
        
        // Save original image for reference
        self.originalCapturedImage = capturedImage
        
        // Start processing
        DispatchQueue.main.async {
            self.isProcessing = true
        }
        
        // Check if model is loaded
        if model == nil {
            print("⚠️ Model not loaded, attempting to reload...")
            loadModel()
            
            // If still nil after reload attempt, return with error
            guard model != nil else {
                print("❌ Failed to load model after retry")
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.savedImage = capturedImage // Show original image
                }
                return
            }
        }
        
        // Ensure proper image orientation and convert to CIImage
        let orientedImage = fixOrientation(capturedImage)
        print("📏 Image dimensions after orientation fix: \(orientedImage.size)")
        
        guard let ciImage = CIImage(image: orientedImage) else {
            print("Failed to convert UIImage to CIImage")
            DispatchQueue.main.async {
                self.isProcessing = false
                self.savedImage = capturedImage
            }
            return
        }
        print("Successfully converted UIImage to CIImage")

        // Perform the Vision request asynchronously
        guard let request = visionRequest else {
            print("❌ Vision request not setup properly")
            DispatchQueue.main.async {
                self.isProcessing = false
                self.savedImage = capturedImage
            }
            return
        }
        print("✅ Vision request ready")

        // Create image request handler with orientation information
        let orientation = convertOrientation(orientedImage.imageOrientation)
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation, options: [:])
        print("✅ Created VNImageRequestHandler")
        
        DispatchQueue.global(qos: .userInitiated).async {
            print("🔍 Starting object detection...")
            do {
                try handler.perform([request])
                print("✅ Handler performed request successfully")
            } catch {
                print("❌ Error performing Vision request: \(error)")
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.savedImage = capturedImage
                }
            }
        }
    }
    
    // Model for storing detected object data for UI
    struct DetectedObject: Identifiable {
        let id = UUID()
        let label: String
        let confidence: Float
        let boundingBox: CGRect
    }
    
    // For future implementation: Save the processed image to local storage
    // private func saveImageLocally(_ image: UIImage) {
    //     // Implementation would go here
    // }
    
    // Fix image orientation to ensure proper processing
    private func fixOrientation(_ image: UIImage) -> UIImage {
        // If the orientation is already up, return the image as is
        if image.imageOrientation == .up {
            return image
        }
        
        // Create a new CGContext and draw the image with the correct orientation
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        print("🔄 Fixed image orientation from \(image.imageOrientation.rawValue) to .up")
        return normalizedImage
    }
    
    // Extension to convert UIImage.Orientation to CGImagePropertyOrientation
    private func convertOrientation(_ orientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch orientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
