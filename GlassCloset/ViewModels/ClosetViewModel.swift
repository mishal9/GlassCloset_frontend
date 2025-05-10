//
//  ClosetViewModel.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import Foundation
import SwiftUI
import Combine

class ClosetViewModel: ObservableObject {
    // Published properties for UI updates
    @Published var clothingItems: [ClothingItem] = []
    @Published var filteredItems: [ClothingItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedFilter: String = "All"
    @Published var searchText: String = ""
    
    // Services
    private let apiService = APIService.shared
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Set up filtering based on search text and category filter
        $searchText
            .combineLatest($selectedFilter, $clothingItems)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { [weak self] (searchText, filter, items) -> [ClothingItem] in
                self?.filterItems(items: items, searchText: searchText, filter: filter) ?? []
            }
            .assign(to: &$filteredItems)
    }
    
    /// Fetches clothing items for the current logged-in user
    func fetchUserClothingItems() {
        isLoading = true
        errorMessage = nil
        
        apiService.fetchUserClothingItems { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let items):
                    self?.clothingItems = items
                    print("📱 Fetched \(items.count) clothing items")
                case .failure(let error):
                    self?.errorMessage = "Failed to load your closet: \(error.localizedDescription)"
                    print("❌ Error fetching clothing items: \(error)")
                }
            }
        }
    }
    
    /// Filters items based on search text and category filter
    private func filterItems(items: [ClothingItem], searchText: String, filter: String) -> [ClothingItem] {
        var filtered = items
        
        // Apply category filter if not "All"
        if filter != "All" {
            filtered = filtered.filter { item in
                let garmentType = item.attributes.garmentType.lowercased()
                return matchesCategory(garmentType: garmentType, category: filter)
            }
        }
        
        // Apply search text filter if not empty
        if !searchText.isEmpty {
            let searchTerms = searchText.lowercased().split(separator: " ").map { String($0) }
            
            filtered = filtered.filter { item in
                return matchesSearchTerms(item: item, searchTerms: searchTerms)
            }
        }
        
        return filtered
    }
    
    /// Helper method to check if a garment type matches a category
    private func matchesCategory(garmentType: String, category: String) -> Bool {
        switch category {
        case "Tops":
            let topTypes = ["shirt", "t-shirt", "blouse", "sweater", "hoodie", "sweatshirt", "tank top", "polo"]
            return topTypes.contains { garmentType.contains($0) }
            
        case "Bottoms":
            let bottomTypes = ["pants", "jeans", "shorts", "skirt", "trousers", "leggings"]
            return bottomTypes.contains { garmentType.contains($0) }
            
        case "Dresses":
            let dressTypes = ["dress", "gown", "jumpsuit"]
            return dressTypes.contains { garmentType.contains($0) }
            
        case "Outerwear":
            let outerwearTypes = ["jacket", "coat", "blazer", "cardigan", "vest"]
            return outerwearTypes.contains { garmentType.contains($0) }
            
        case "Shoes":
            let shoeTypes = ["shoes", "sneakers", "boots", "sandals", "heels"]
            return shoeTypes.contains { garmentType.contains($0) }
            
        case "Accessories":
            let accessoryTypes = ["hat", "scarf", "gloves", "belt", "tie", "jewelry", "watch", "bag", "purse", "backpack"]
            return accessoryTypes.contains { garmentType.contains($0) }
            
        default:
            return true
        }
    }
    
    /// Helper method to check if an item matches search terms
    private func matchesSearchTerms(item: ClothingItem, searchTerms: [String]) -> Bool {
        let attributes = item.attributes
        
        // Create searchable text from all attributes
        let attributeTexts = [
            attributes.garmentType,
            attributes.material,
            attributes.style,
            attributes.pattern,
            attributes.season,
            attributes.occasion,
            attributes.fit,
            attributes.brand
        ]
        let searchableText = attributeTexts.joined(separator: " ").lowercased()
        
        // Add colors to searchable text
        let colorText = (attributes.mainColors + attributes.secondaryColors).joined(separator: " ").lowercased()
        let fullSearchText = searchableText + " " + colorText
        
        // Item matches if it contains all search terms
        return searchTerms.allSatisfy { fullSearchText.contains($0) }
    }
    
    /// Sorts items by date added (newest first)
    func sortedByDateAdded(_ items: [ClothingItem]) -> [ClothingItem] {
        return items.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    /// Deletes a clothing item by its ID
    func deleteClothingItem(itemId: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        apiService.deleteClothingItem(itemId: itemId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(_):
                    // Remove the item from the local arrays
                    self?.clothingItems.removeAll { $0.id == itemId }
                    print("📱 Successfully deleted clothing item with ID: \(itemId)")
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to delete item: \(error.localizedDescription)"
                    print("❌ Error deleting clothing item: \(error)")
                    completion(false)
                }
            }
        }
    }
}
