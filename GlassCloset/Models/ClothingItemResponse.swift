//
//  ClothingItemResponse.swift
//  GlassCloset
//
//  Created by Mishal on 5/10/25.
//

import Foundation

// Wrapper model to decode the API response structure
struct ClothingItemResponse: Codable {
    let clothingItems: [ClothingItem]
    
    enum CodingKeys: String, CodingKey {
        case clothingItems = "clothing_items"
    }
}
