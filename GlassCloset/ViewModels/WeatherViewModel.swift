//
//  WeatherViewModel.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import Foundation
import SwiftUI
import Combine

class WeatherViewModel: ObservableObject {
    // Published properties that the UI can observe
    @Published var weatherData: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Reference to the weather service
    private let weatherService = WeatherService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Subscribe to changes in the weather service
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Subscribe to current weather updates
        weatherService.$currentWeather
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weatherData in
                self?.weatherData = weatherData
            }
            .store(in: &cancellables)
        
        // Subscribe to loading state updates
        weatherService.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)
        
        // Subscribe to error updates
        weatherService.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    switch error {
                    case .locationPermissionDenied:
                        self?.errorMessage = "Location access denied. Please enable location services in Settings."
                    case .locationError:
                        self?.errorMessage = "Unable to determine your location."
                    case .weatherDataUnavailable:
                        self?.errorMessage = "Weather data is currently unavailable."
                    case .networkError(let underlyingError):
                        self?.errorMessage = "Network error: \(underlyingError.localizedDescription)"
                    case .invalidResponse:
                        self?.errorMessage = "Invalid response from weather service."
                    case .geocodingFailed:
                        self?.errorMessage = "Could not find that location. Please try another city name."
                    }
                } else {
                    self?.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }
    
    // Function to request weather update
    func refreshWeather() {
        weatherService.requestWeatherUpdate()
    }
    
    // Function to fetch weather for a specific city
    func fetchWeather(for city: String) {
        weatherService.fetchWeather(for: city)
    }
    
    // Helper function to get weather icon based on condition
    func weatherIcon(for condition: String?) -> String {
        guard let condition = condition?.lowercased() else {
            return "cloud.fill"
        }
        
        if condition.contains("clear") || condition.contains("sunny") {
            return "sun.max.fill"
        } else if condition.contains("partly") && condition.contains("cloud") {
            return "cloud.sun.fill"
        } else if condition.contains("cloud") {
            return "cloud.fill"
        } else if condition.contains("rain") || condition.contains("drizzle") {
            return "cloud.rain.fill"
        } else if condition.contains("snow") || condition.contains("sleet") {
            return "cloud.snow.fill"
        } else if condition.contains("fog") || condition.contains("mist") {
            return "cloud.fog.fill"
        } else if condition.contains("thunder") || condition.contains("lightning") {
            return "cloud.bolt.fill"
        } else if condition.contains("wind") {
            return "wind"
        } else {
            return "cloud.fill"
        }
    }
    
    // Function to get clothing recommendations based on weather
    func getClothingRecommendations() -> [String] {
        guard let weather = weatherData else {
            return ["Unable to provide recommendations without weather data"]
        }
        
        var recommendations: [String] = []
        
        // Temperature-based recommendations
        if weather.temperature < 0 {
            recommendations.append("Heavy winter coat")
            recommendations.append("Thermal layers")
            recommendations.append("Winter hat and gloves")
            recommendations.append("Insulated boots")
        } else if weather.temperature < 10 {
            recommendations.append("Winter coat or heavy jacket")
            recommendations.append("Sweater or fleece")
            recommendations.append("Scarf and gloves")
        } else if weather.temperature < 15 {
            recommendations.append("Light jacket or heavy sweater")
            recommendations.append("Long-sleeve shirt")
            recommendations.append("Jeans or pants")
        } else if weather.temperature < 20 {
            recommendations.append("Light sweater or long-sleeve shirt")
            recommendations.append("Light pants or jeans")
        } else if weather.temperature < 25 {
            recommendations.append("T-shirt or short-sleeve shirt")
            recommendations.append("Light pants or shorts")
        } else {
            recommendations.append("Light, breathable clothing")
            recommendations.append("Shorts or light pants")
            recommendations.append("T-shirt or tank top")
        }
        
        // Condition-based recommendations
        if weather.condition.lowercased().contains("rain") {
            recommendations.append("Rain jacket or umbrella")
            recommendations.append("Waterproof shoes")
        } else if weather.condition.lowercased().contains("snow") {
            recommendations.append("Waterproof boots")
            recommendations.append("Snow jacket")
        } else if weather.condition.lowercased().contains("wind") {
            recommendations.append("Windbreaker")
        } else if weather.condition.lowercased().contains("sunny") || weather.condition.lowercased().contains("clear") {
            recommendations.append("Sunglasses")
            recommendations.append("Sunscreen")
            if weather.temperature > 20 {
                recommendations.append("Hat or cap")
            }
        }
        
        return recommendations
    }
}
