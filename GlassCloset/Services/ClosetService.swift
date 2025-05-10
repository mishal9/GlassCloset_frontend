//
//  ClosetService.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import Foundation
import SwiftUI
import Combine

class ClosetService: ObservableObject {
    // Singleton instance
    static let shared = ClosetService()
    
    // API Service
    private let apiService = APIService.shared
    
    // Published properties
    @Published var userClothingItems: [ClothingItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Private initializer for singleton
    private init() {}
    
    /// Fetches all clothing items for the current logged-in user
    func fetchUserClothingItems(completion: @escaping (Result<[ClothingItem], Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        apiService.fetchUserClothingItems { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let items):
                    self?.userClothingItems = items
                    completion(.success(items))
                case .failure(let error):
                    self?.errorMessage = "Failed to load your closet: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Filters clothing items by category
    func filterItemsByCategory(_ items: [ClothingItem], category: String) -> [ClothingItem] {
        guard category != "All" else { return items }
        
        return items.filter { item in
            let garmentType = item.attributes.garmentType.lowercased()
            
            // Map filter categories to potential garment types
            switch category {
            case "Tops":
                return ["shirt", "t-shirt", "blouse", "sweater", "hoodie", "sweatshirt", "tank top", "polo"].contains { garmentType.contains($0.lowercased()) }
            case "Bottoms":
                return ["pants", "jeans", "shorts", "skirt", "trousers", "leggings"].contains { garmentType.contains($0.lowercased()) }
            case "Dresses":
                return ["dress", "gown", "jumpsuit"].contains { garmentType.contains($0.lowercased()) }
            case "Outerwear":
                return ["jacket", "coat", "blazer", "cardigan", "vest"].contains { garmentType.contains($0.lowercased()) }
            case "Shoes":
                return ["shoes", "sneakers", "boots", "sandals", "heels"].contains { garmentType.contains($0.lowercased()) }
            case "Accessories":
                return ["hat", "scarf", "gloves", "belt", "tie", "jewelry", "watch", "bag", "purse", "backpack"].contains { garmentType.contains($0.lowercased()) }
            default:
                return true
            }
        }
    }
    
    /// Searches clothing items by search text
    func searchItems(_ items: [ClothingItem], searchText: String) -> [ClothingItem] {
        guard !searchText.isEmpty else { return items }
        
        let searchTerms = searchText.lowercased().split(separator: " ").map { String($0) }
        
        return items.filter { item in
            let attributes = item.attributes
            let searchableText = [
                attributes.garmentType,
                attributes.material,
                attributes.style,
                attributes.pattern,
                attributes.season,
                attributes.occasion,
                attributes.fit,
                attributes.brand
            ].joined(separator: " ").lowercased()
            
            // Also include colors in search
            let colorText = (attributes.mainColors + attributes.secondaryColors).joined(separator: " ").lowercased()
            let fullSearchText = searchableText + " " + colorText
            
            // Item matches if it contains all search terms
            return searchTerms.allSatisfy { fullSearchText.contains($0) }
        }
    }
}
