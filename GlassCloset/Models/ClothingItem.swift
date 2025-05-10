//
//  ClothingItem.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import Foundation
import SwiftUI

// Struct to hold clothing analysis attributes
struct ClothingAttributes: Codable {
    var mainColors: [String]
    var secondaryColors: [String]
    var garmentType: String
    var pattern: String
    var material: String
    var style: String
    var season: String
    var occasion: String
    var fit: String
    var brand: String
    var id: String?
    var imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case mainColors = "main_colors"
        case secondaryColors = "secondary_colors"
        case garmentType = "garment_type"
        case pattern, material, style, season, occasion, fit, brand
    }
    
    /// Mock data for previews and testing
    static var mock: ClothingAttributes {
        ClothingAttributes(
            mainColors: ["Navy Blue"],
            secondaryColors: ["White"],
            garmentType: "Hoodie",
            pattern: "Solid",
            material: "Cotton",
            style: "Casual",
            season: "Fall",
            occasion: "Casual",
            fit: "Regular",
            brand: "Unknown"
        )
    }
    
    init(mainColors: [String] = [], secondaryColors: [String] = [], garmentType: String = "", 
         pattern: String = "", material: String = "", style: String = "", 
         season: String = "", occasion: String = "", fit: String = "", brand: String = "",
         id: String? = nil, imageUrl: String? = nil) {
        self.mainColors = mainColors
        self.secondaryColors = secondaryColors
        self.garmentType = garmentType
        self.pattern = pattern
        self.material = material
        self.style = style
        self.season = season
        self.occasion = occasion
        self.fit = fit
        self.brand = brand
        self.id = id
        self.imageUrl = imageUrl
    }
    
    /// Returns true if essential attributes are empty
    var isEmpty: Bool {
        return mainColors.isEmpty && 
               garmentType.isEmpty && 
               material.isEmpty && 
               pattern.isEmpty && 
               style.isEmpty
    }
    
    /// Returns a formatted string representation of the attributes
    var formattedString: String {
        var result = ""
        
        if !garmentType.isEmpty {
            result += "Type: \(garmentType.capitalized)\n"
        }
        
        if !mainColors.isEmpty {
            let colorsList = mainColors.map { $0.capitalized }.joined(separator: ", ")
            result += "Main Colors: \(colorsList)\n"
        }
        
        if !secondaryColors.isEmpty && secondaryColors.first != "Not detected" {
            let colorsList = secondaryColors.map { $0.capitalized }.joined(separator: ", ")
            result += "Accent Colors: \(colorsList)\n"
        }
        
        if !material.isEmpty && material != "Not detected" {
            result += "Material: \(material.capitalized)\n"
        }
        
        if !pattern.isEmpty && pattern != "Not detected" {
            result += "Pattern: \(pattern.capitalized)\n"
        }
        
        if !style.isEmpty && style != "Not detected" {
            result += "Style: \(style.capitalized)\n"
        }
        
        if !season.isEmpty && season != "Not detected" {
            result += "Season: \(season.capitalized)\n"
        }
        
        if !occasion.isEmpty && occasion != "Not detected" {
            result += "Occasion: \(occasion.capitalized)\n"
        }
        
        if !fit.isEmpty && fit != "Not detected" {
            result += "Fit: \(fit.capitalized)\n"
        }
        
        if !brand.isEmpty && brand != "Not detected" {
            result += "Brand: \(brand)\n"
        }
        
        return result.isEmpty ? "No attributes available" : result
    }
    
    /// Converts a color name string to a SwiftUI Color
    func colorFromString(_ colorName: String) -> Color {
        let normalizedColor = colorName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Basic color mapping
        switch normalizedColor {
        case "red", "crimson", "scarlet":
            return .red
        case "blue", "navy", "navy blue", "royal blue":
            return Color(red: 0, green: 0, blue: 0.8)
        case "green", "forest green", "emerald":
            return .green
        case "yellow", "gold":
            return .yellow
        case "orange", "tangerine":
            return .orange
        case "purple", "violet", "lavender":
            return .purple
        case "pink", "magenta", "fuchsia":
            return .pink
        case "brown", "tan", "chocolate":
            return Color(red: 0.6, green: 0.4, blue: 0.2)
        case "gray", "grey":
            return .gray
        case "black":
            return .black
        case "white", "ivory", "cream":
            return .white
        case "teal", "turquoise", "aqua":
            return Color(red: 0, green: 0.5, blue: 0.5)
        case "beige", "khaki":
            return Color(red: 0.96, green: 0.96, blue: 0.86)
        case "maroon", "burgundy":
            return Color(red: 0.5, green: 0, blue: 0)
        case "olive", "olive green":
            return Color(red: 0.5, green: 0.5, blue: 0)
        default:
            // Default to a medium gray if color not recognized
            return .gray
        }
    }
    
    /// Get the primary color from the main colors array
    var primaryColor: Color {
        if let firstColor = mainColors.first {
            return colorFromString(firstColor)
        }
        return .gray
    }
    
    /// Get the secondary color from the secondary colors array
    var secondaryColor: Color {
        if let firstColor = secondaryColors.first, firstColor != "Not detected" {
            return colorFromString(firstColor)
        }
        return .clear
    }
}

// Main clothing item model
struct ClothingItem: Identifiable, Codable {
    var id: String
    var attributes: ClothingAttributes
    var imageUrl: String?
    var dateAdded: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "clothing_item_id"
        case attributes = "attributes"
        case imageUrl = "image_url"
        // dateAdded is not in the API response, so we don't include it in CodingKeys
    }
    
    init(id: String = UUID().uuidString, 
         attributes: ClothingAttributes = ClothingAttributes(), 
         imageUrl: String? = nil, 
         dateAdded: Date = Date()) {
        self.id = id
        self.attributes = attributes
        self.imageUrl = imageUrl
        self.dateAdded = dateAdded
    }
    
    // Custom init from decoder to handle the missing dateAdded field
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the properties from the container
        id = try container.decode(String.self, forKey: .id)
        attributes = try container.decode(ClothingAttributes.self, forKey: .attributes)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        
        // Set dateAdded to current date since it's not in the API response
        dateAdded = Date()
    }
    
    // Generate a name based on attributes
    var name: String {
        let typeStr = attributes.garmentType.isEmpty ? "Item" : attributes.garmentType.capitalized
        
        var colorStr = ""
        if let firstColor = attributes.mainColors.first {
            colorStr = firstColor.capitalized
        }
        
        return colorStr.isEmpty ? typeStr : "\(colorStr) \(typeStr)"
    }
}
