//
//  ClothingDetector.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import UIKit
import Vision
import CoreML

class ClothingDetector {
    private var model: VNCoreMLModel!
    
    init?() {
        guard let coreMLModel = try? YOLOv3Tiny(configuration: MLModelConfiguration()).model,
              let visionModel = try? VNCoreMLModel(for: coreMLModel) else {
            print("Failed to load YOLOv3Tiny model")
            return nil
        }
        self.model = visionModel
    }
    
    func detectClothing(in image: UIImage, completion: @escaping ([VNRecognizedObjectObservation]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNRecognizedObjectObservation] {
                completion(results)
            } else {
                print("Detection failed: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
            }
        }
        
        request.imageCropAndScaleOption = .scaleFill
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
