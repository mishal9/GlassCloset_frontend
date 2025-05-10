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
    
    // Custom init from decoder to handle null values and other edge cases
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle arrays with proper error handling
        do {
            // First try to decode as an array of strings
            mainColors = try container.decode([String].self, forKey: .mainColors)
        } catch {
            print("Error decoding mainColors as array: \(error)")
            // If that fails, try to decode as a single string and convert to array
            do {
                if let colorString = try? container.decodeIfPresent(String.self, forKey: .mainColors) {
                    mainColors = [colorString]
                } else {
                    mainColors = []
                }
            } catch {
                print("Error decoding mainColors as string: \(error)")
                mainColors = []
            }
        }
        
        do {
            secondaryColors = try container.decode([String].self, forKey: .secondaryColors)
        } catch {
            print("Error decoding secondaryColors: \(error)")
            // If that fails, try to decode as a single string and convert to array
            do {
                if let colorString = try? container.decodeIfPresent(String.self, forKey: .secondaryColors) {
                    secondaryColors = [colorString]
                } else {
                    secondaryColors = []
                }
            } catch {
                print("Error decoding secondaryColors as string: \(error)")
                secondaryColors = []
            }
        }
        
        // Handle strings with proper null handling
        do {
            if let garmentTypeValue = try? container.decodeIfPresent(String.self, forKey: .garmentType) {
                garmentType = garmentTypeValue == "null" ? "" : garmentTypeValue
            } else {
                garmentType = ""
            }
        } catch {
            print("Error decoding garmentType: \(error)")
            garmentType = ""
        }
        
        do {
            if let patternValue = try? container.decodeIfPresent(String.self, forKey: .pattern) {
                pattern = patternValue == "null" ? "" : patternValue
            } else {
                pattern = ""
            }
        } catch {
            print("Error decoding pattern: \(error)")
            pattern = ""
        }
        
        do {
            if let materialValue = try? container.decodeIfPresent(String.self, forKey: .material) {
                material = materialValue == "null" ? "" : materialValue
            } else {
                material = ""
            }
        } catch {
            print("Error decoding material: \(error)")
            material = ""
        }
        
        do {
            if let styleValue = try? container.decodeIfPresent(String.self, forKey: .style) {
                style = styleValue == "null" ? "" : styleValue
            } else {
                style = ""
            }
        } catch {
            print("Error decoding style: \(error)")
            style = ""
        }
        
        do {
            if let seasonValue = try? container.decodeIfPresent(String.self, forKey: .season) {
                season = seasonValue == "null" ? "" : seasonValue
            } else {
                season = ""
            }
        } catch {
            print("Error decoding season: \(error)")
            season = ""
        }
        
        do {
            if let occasionValue = try? container.decodeIfPresent(String.self, forKey: .occasion) {
                occasion = occasionValue == "null" ? "" : occasionValue
            } else {
                occasion = ""
            }
        } catch {
            print("Error decoding occasion: \(error)")
            occasion = ""
        }
        
        do {
            if let fitValue = try? container.decodeIfPresent(String.self, forKey: .fit) {
                fit = fitValue == "null" ? "" : fitValue
            } else {
                fit = ""
            }
        } catch {
            print("Error decoding fit: \(error)")
            fit = ""
        }
        
        do {
            if let brandValue = try? container.decodeIfPresent(String.self, forKey: .brand) {
                brand = brandValue == "null" ? "" : brandValue
            } else {
                brand = ""
            }
        } catch {
            print("Error decoding brand: \(error)")
            brand = ""
        }
        
        // Optional fields
        id = nil
        imageUrl = nil
    }
    
    /// Returns true if essential attributes are empty
    var isEmpty: Bool {
        return mainColors.isEmpty && 
               (garmentType.isEmpty || garmentType == "null" || garmentType == "Not detected") && 
               (material.isEmpty || material == "null" || material == "Not detected") && 
               (pattern.isEmpty || pattern == "null" || pattern == "Not detected") && 
               (style.isEmpty || style == "null" || style == "Not detected")
    }
    
    /// Returns a formatted string representation of the attributes
    var formattedString: String {
        var result = ""
        
        if !garmentType.isEmpty && garmentType != "null" && garmentType != "Not detected" {
            result += "Type: \(garmentType.capitalized)\n"
        }
        
        if !mainColors.isEmpty {
            let colorsList = mainColors.map { $0.capitalized }.joined(separator: ", ")
            result += "Main Colors: \(colorsList)\n"
        }
        
        if !secondaryColors.isEmpty && secondaryColors.first != "Not detected" && secondaryColors.first != "null" {
            let colorsList = secondaryColors.map { $0.capitalized }.joined(separator: ", ")
            result += "Accent Colors: \(colorsList)\n"
        }
        
        if !material.isEmpty && material != "Not detected" && material != "null" {
            result += "Material: \(material.capitalized)\n"
        }
        
        if !pattern.isEmpty && pattern != "Not detected" && pattern != "null" {
            result += "Pattern: \(pattern.capitalized)\n"
        }
        
        if !style.isEmpty && style != "Not detected" && style != "null" {
            result += "Style: \(style.capitalized)\n"
        }
        
        if !season.isEmpty && season != "Not detected" && season != "null" {
            result += "Season: \(season.capitalized)\n"
        }
        
        if !occasion.isEmpty && occasion != "Not detected" && occasion != "null" {
            result += "Occasion: \(occasion.capitalized)\n"
        }
        
        if !fit.isEmpty && fit != "Not detected" && fit != "null" {
            result += "Fit: \(fit.capitalized)\n"
        }
        
        if !brand.isEmpty && brand != "Not detected" && brand != "null" {
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
        if let firstColor = mainColors.first, firstColor != "null" && firstColor != "Not detected" {
            return colorFromString(firstColor)
        }
        return .gray
    }
    
    /// Get the secondary color from the secondary colors array
    var secondaryColor: Color {
        if let firstColor = secondaryColors.first, firstColor != "Not detected" && firstColor != "null" {
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
        case id
        case attributes
        case imageUrl = "image_url"
        case dateAdded = "created_at"
        case userId = "user_id"
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
    
    // Custom init from decoder to handle the date format from the API
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the properties from the container with error handling
        do {
            id = try container.decode(String.self, forKey: .id)
        } catch {
            print("Error decoding id: \(error)")
            id = UUID().uuidString // Generate a fallback ID
        }
        
        do {
            attributes = try container.decode(ClothingAttributes.self, forKey: .attributes)
        } catch {
            print("Error decoding attributes: \(error)")
            attributes = ClothingAttributes() // Use empty attributes as fallback
        }
        
        do {
            imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        } catch {
            print("Error decoding imageUrl: \(error)")
            imageUrl = nil
        }
        
        // Parse the created_at date string with error handling
        do {
            let dateString = try container.decode(String.self, forKey: .dateAdded)
            
            // Create a date formatter for ISO 8601 format with fractional seconds and timezone
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = dateFormatter.date(from: dateString) {
                dateAdded = date
            } else {
                // Try alternative date formats if the first one fails
                let alternativeFormatter = DateFormatter()
                alternativeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZ"
                
                if let date = alternativeFormatter.date(from: dateString) {
                    dateAdded = date
                } else {
                    print("⚠️ Could not parse date: \(dateString)")
                    dateAdded = Date() // Fallback to current date
                }
            }
        } catch {
            print("Error decoding dateAdded: \(error)")
            dateAdded = Date() // Fallback to current date
        }
        
        // We don't need to do anything with userId, but we could store it if needed
    }
    
    // Custom encode method to match the API format
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(attributes, forKey: .attributes)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        
        // Format the date as ISO 8601 string
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateString = dateFormatter.string(from: dateAdded)
        try container.encode(dateString, forKey: .dateAdded)
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
    
    // Mock items for previews and testing
    static var mockItems: [ClothingItem] = [
        ClothingItem(
            id: "1",
            attributes: ClothingAttributes(
                mainColors: ["Navy Blue"],
                secondaryColors: ["White"],
                garmentType: "Hoodie",
                pattern: "Solid",
                material: "Cotton",
                style: "Casual",
                season: "Fall",
                occasion: "Casual",
                fit: "Regular",
                brand: "Nike"
            ),
            imageUrl: nil,
            dateAdded: Date()
        ),
        ClothingItem(
            id: "2",
            attributes: ClothingAttributes(
                mainColors: ["Black"],
                secondaryColors: ["Red"],
                garmentType: "T-Shirt",
                pattern: "Graphic",
                material: "Cotton",
                style: "Casual",
                season: "Summer",
                occasion: "Casual",
                fit: "Slim",
                brand: "Adidas"
            ),
            imageUrl: nil,
            dateAdded: Date().addingTimeInterval(-86400) // 1 day ago
        ),
        ClothingItem(
            id: "3",
            attributes: ClothingAttributes(
                mainColors: ["Blue"],
                secondaryColors: [],
                garmentType: "Jeans",
                pattern: "Solid",
                material: "Denim",
                style: "Casual",
                season: "All Season",
                occasion: "Casual",
                fit: "Slim",
                brand: "Levi's"
            ),
            imageUrl: nil,
            dateAdded: Date().addingTimeInterval(-172800) // 2 days ago
        )
    ]
}
