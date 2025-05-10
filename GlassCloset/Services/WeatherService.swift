//
//  WeatherService.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import Foundation
import CoreLocation

// Weather data model
struct WeatherData: Codable {
    let temperature: Double
    let feelsLike: Double
    let condition: String
    let location: String
    let humidity: Double
    let windSpeed: Double
    
    // Format temperature as a string with degree symbol
    var temperatureString: String {
        return String(format: "%.0f°", temperature)
    }
    
    // Format feels like temperature as a string
    var feelsLikeString: String {
        return "Feels like " + String(format: "%.0f°", feelsLike)
    }
}

// Open-Meteo API response models
struct OpenMeteoResponse: Codable {
    let current: CurrentWeather
    let current_units: CurrentUnits
    let daily: DailyWeather?
    
    struct CurrentWeather: Codable {
        let temperature_2m: Double
        let apparent_temperature: Double
        let relative_humidity_2m: Double
        let weather_code: Int
        let wind_speed_10m: Double
    }
    
    struct CurrentUnits: Codable {
        let temperature_2m: String
        let apparent_temperature: String
        let relative_humidity_2m: String
        let wind_speed_10m: String
    }
    
    struct DailyWeather: Codable {
        let time: [String]?
        let weather_code: [Int]?
        let temperature_2m_max: [Double]?
        let temperature_2m_min: [Double]?
    }
}

// Enum for weather errors
enum WeatherError: Error {
    case locationPermissionDenied
    case locationError
    case weatherDataUnavailable
    case networkError(Error)
    case invalidResponse
    case geocodingFailed
}

// Weather service class to handle weather data fetching
class WeatherService: NSObject, ObservableObject {
    // Published properties to notify observers when data changes
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    @Published var error: WeatherError?
    
    // Location manager to get user's location
    private let locationManager = CLLocationManager()
    
    // Open-Meteo API base URL
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    private let geocodingURL = "https://geocoding-api.open-meteo.com/v1/search"
    
    // Singleton instance
    static let shared = WeatherService()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // Setup location manager
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer // Lower accuracy for weather is sufficient
        
        // We'll check authorization status in locationManagerDidChangeAuthorization instead of requesting immediately
    }
    
    // Request location and weather update
    func requestWeatherUpdate() {
        isLoading = true
        error = nil
        
        // First check if location services are enabled at the system level
        if CLLocationManager.locationServicesEnabled() {
            // Then check the app's authorization status
            let status = locationManager.authorizationStatus
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                // Already authorized, request location
                locationManager.requestLocation()
                
            case .notDetermined:
                // Will request authorization in locationManagerDidChangeAuthorization
                // The delegate will be called automatically
                break
                
            case .denied, .restricted:
                // User has denied location access
                isLoading = false
                error = .locationPermissionDenied
                
            @unknown default:
                isLoading = false
                error = .locationError
            }
        } else {
            // Location services disabled at system level
            isLoading = false
            error = .locationPermissionDenied
        }
    }
    
    // Convert weather code to condition string
    private func weatherConditionFrom(code: Int) -> String {
        switch code {
        case 0:
            return "Clear sky"
        case 1:
            return "Mainly clear"
        case 2:
            return "Partly cloudy"
        case 3:
            return "Overcast"
        case 45, 48:
            return "Fog"
        case 51, 53, 55:
            return "Drizzle"
        case 56, 57:
            return "Freezing drizzle"
        case 61, 63, 65:
            return "Rain"
        case 66, 67:
            return "Freezing rain"
        case 71, 73, 75:
            return "Snow"
        case 77:
            return "Snow grains"
        case 80, 81, 82:
            return "Rain showers"
        case 85, 86:
            return "Snow showers"
        case 95:
            return "Thunderstorm"
        case 96, 99:
            return "Thunderstorm with hail"
        default:
            return "Unknown"
        }
    }
    
    // Fetch weather data using Open-Meteo API
    private func fetchWeather(for location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Get location name first
        getLocationName(for: location) { [weak self] locationName in
            guard let self = self else { return }
            
            // Build URL with query parameters
            var components = URLComponents(string: self.baseURL)
            components?.queryItems = [
                URLQueryItem(name: "latitude", value: String(latitude)),
                URLQueryItem(name: "longitude", value: String(longitude)),
                URLQueryItem(name: "current", value: "temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m"),
                URLQueryItem(name: "timezone", value: "auto")
            ]
            
            guard let url = components?.url else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.error = .weatherDataUnavailable
                }
                return
            }
            
            // Create and execute URL request
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        self.isLoading = false
                        self.error = .networkError(error)
                        return
                    }
                    
                    guard let data = data else {
                        self.isLoading = false
                        self.error = .weatherDataUnavailable
                        return
                    }
                    
                    do {
                        // Parse the JSON response
                        let decoder = JSONDecoder()
                        let weatherResponse = try decoder.decode(OpenMeteoResponse.self, from: data)
                        
                        // Convert weather code to condition string
                        let condition = self.weatherConditionFrom(code: weatherResponse.current.weather_code)
                        
                        // Create weather data object
                        let weatherData = WeatherData(
                            temperature: weatherResponse.current.temperature_2m,
                            feelsLike: weatherResponse.current.apparent_temperature,
                            condition: condition,
                            location: locationName,
                            humidity: weatherResponse.current.relative_humidity_2m,
                            windSpeed: weatherResponse.current.wind_speed_10m
                        )
                        
                        self.currentWeather = weatherData
                        self.isLoading = false
                    } catch {
                        print("Decoding error: \(error)")
                        self.isLoading = false
                        self.error = .invalidResponse
                    }
                }
            }
            
            task.resume()
        }
    }
    
    // Get location name from coordinates
    private func getLocationName(for location: CLLocation, completion: @escaping (String) -> Void) {
        // First try to use CoreLocation's reverse geocoding
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first, let locality = placemark.locality {
                completion(locality)
            } else {
                // If CoreLocation fails, use coordinates as location name
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                completion("\(lat.rounded()), \(lon.rounded())")
            }
        }
    }
    
    // Fetch weather for a specific city name
    func fetchWeather(for city: String) {
        isLoading = true
        error = nil
        
        // First geocode the city name to get coordinates
        geocodeCity(city) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let location):
                self.fetchWeather(for: location)
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.error = error
                }
            }
        }
    }
    
    // Geocode city name to coordinates using Open-Meteo Geocoding API
    private func geocodeCity(_ city: String, completion: @escaping (Result<CLLocation, WeatherError>) -> Void) {
        var components = URLComponents(string: geocodingURL)
        components?.queryItems = [
            URLQueryItem(name: "name", value: city),
            URLQueryItem(name: "count", value: "1")
        ]
        
        guard let url = components?.url else {
            completion(.failure(.weatherDataUnavailable))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.weatherDataUnavailable))
                return
            }
            
            do {
                // Parse the geocoding response
                struct GeocodingResponse: Codable {
                    let results: [GeocodingResult]?
                    
                    struct GeocodingResult: Codable {
                        let latitude: Double
                        let longitude: Double
                        let name: String
                    }
                }
                
                let decoder = JSONDecoder()
                let response = try decoder.decode(GeocodingResponse.self, from: data)
                
                if let firstResult = response.results?.first {
                    let location = CLLocation(latitude: firstResult.latitude, longitude: firstResult.longitude)
                    completion(.success(location))
                } else {
                    completion(.failure(.geocodingFailed))
                }
            } catch {
                completion(.failure(.invalidResponse))
            }
        }
        
        task.resume()
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.error = .locationError
            }
            return
        }
        
        fetchWeather(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.error = .locationError
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Request location if authorized
            manager.requestLocation()
            
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.isLoading = false
                self.error = .locationPermissionDenied
            }
            
        case .notDetermined:
            // Request authorization when not determined
            // This is the right place to request authorization to avoid UI blocking
            manager.requestWhenInUseAuthorization()
            
        @unknown default:
            break
        }
    }
}
