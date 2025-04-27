//
//  ImageCropper.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import CoreGraphics
import UIKit


func cropImage(image: UIImage, to boundingBox: CGRect) -> UIImage {
    let width = image.size.width * boundingBox.width
    let height = image.size.height * boundingBox.height
    let x = image.size.width * boundingBox.minX
    let y = image.size.height * (1 - boundingBox.maxY)
    
    let cropRect = CGRect(x: x, y: y, width: width, height: height)
    
    guard let cgImage = image.cgImage?.cropping(to: cropRect) else { return image }
    return UIImage(cgImage: cgImage)
}
