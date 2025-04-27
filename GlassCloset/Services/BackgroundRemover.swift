//
//  BackgroundRemovalService.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import UIKit
import CoreML
import Vision

class BackgroundRemover {
    private var model: VNCoreMLModel!
    
    init?() {
        guard let coreMLModel = try? DeepLabV3(configuration: MLModelConfiguration()).model,
              let visionModel = try? VNCoreMLModel(for: coreMLModel) else {
            print("Failed to load DeepLabV3 model")
            return nil
        }
        self.model = visionModel
    }
    
    func removeBackground(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let observations = request.results as? [VNPixelBufferObservation],
                  let pixelBuffer = observations.first?.pixelBuffer else {
                print("Segmentation failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            let maskImage = self.createMaskImage(from: pixelBuffer)
            let finalImage = self.applyMask(maskImage: maskImage, to: image)
            completion(finalImage)
        }
        
        request.imageCropAndScaleOption = .scaleFill
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    private func createMaskImage(from pixelBuffer: CVPixelBuffer) -> UIImage {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)!
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)!
        
        let maskCgImage = context.makeImage()!
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        
        return UIImage(cgImage: maskCgImage)
    }
    
    private func applyMask(maskImage: UIImage, to originalImage: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(originalImage.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        guard let maskRef = maskImage.cgImage else { return nil }
        guard let masked = originalImage.cgImage?.masking(maskRef) else { return nil }
        
        context.draw(masked, in: CGRect(origin: .zero, size: originalImage.size))
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
}
