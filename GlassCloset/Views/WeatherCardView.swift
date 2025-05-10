//
//  WeatherCardView.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import SwiftUI

struct WeatherCardView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingRecommendations = false
    
    init(viewModel: WeatherViewModel = WeatherViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.xs) {
            if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else if let weatherData = viewModel.weatherData {
                weatherContentView(weatherData: weatherData)
            } else {
                placeholderView
            }
        }
        .glassCard(cornerRadius: GlassDesignSystem.Radius.xl)
        .floatingEffect(intensity: 0.5)
        .padding(.horizontal, GlassDesignSystem.Spacing.md)
        .onAppear {
            // Request weather update when the view appears
            viewModel.refreshWeather()
        }
        .sheet(isPresented: $showingRecommendations) {
            recommendationsView
        }
    }
    
    // Loading state view
    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .padding(GlassDesignSystem.Spacing.md)
            Spacer()
        }
    }
    
    // Error state view
    private func errorView(message: String) -> some View {
        VStack(alignment: .center, spacing: GlassDesignSystem.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 30))
                .foregroundColor(.orange)
            
            Text(message)
                .font(GlassDesignSystem.Typography.bodyMedium)
                .multilineTextAlignment(.center)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Button("Retry") {
                viewModel.refreshWeather()
            }
            .buttonStyle(.bordered)
            .padding(.top, GlassDesignSystem.Spacing.xs)
        }
        .padding(GlassDesignSystem.Spacing.md)
        .frame(maxWidth: .infinity)
    }
    
    // Placeholder view when no data is available
    private var placeholderView: some View {
        HStack(alignment: .center, spacing: GlassDesignSystem.Spacing.md) {
            Image(systemName: "cloud.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                .font(.system(size: 30))
            
            VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.xxs) {
                Text("--°")
                    .font(GlassDesignSystem.Typography.title3)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Text("Feels like --°")
                    .font(GlassDesignSystem.Typography.bodySmall)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7))
            }
            
            Spacer()
            
            Text("--")
                .font(GlassDesignSystem.Typography.bodyMedium)
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
        .padding(GlassDesignSystem.Spacing.md)
    }
    
    // Weather content view when data is available
    private func weatherContentView(weatherData: WeatherData) -> some View {
        VStack(spacing: GlassDesignSystem.Spacing.sm) {
            HStack(alignment: .center, spacing: GlassDesignSystem.Spacing.md) {
                Image(systemName: viewModel.weatherIcon(for: weatherData.condition))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(getIconColor(for: weatherData.condition), colorScheme == .dark ? Color.white : Color.white)
                    .font(.system(size: 30))
                
                VStack(alignment: .leading, spacing: GlassDesignSystem.Spacing.xxs) {
                    Text(weatherData.temperatureString)
                        .font(GlassDesignSystem.Typography.title3)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text(weatherData.feelsLikeString)
                        .font(GlassDesignSystem.Typography.bodySmall)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7))
                }
                
                Spacer()
                
                Text(weatherData.location)
                    .font(GlassDesignSystem.Typography.bodyMedium)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            
            // Additional weather details
            HStack(spacing: GlassDesignSystem.Spacing.lg) {
                weatherDetailItem(icon: "humidity.fill", value: String(format: "%.0f%%", weatherData.humidity))
                weatherDetailItem(icon: "wind", value: String(format: "%.1f km/h", weatherData.windSpeed))
                
                Spacer()
                
                Button(action: {
                    showingRecommendations = true
                }) {
                    Text("Outfit Tips")
                        .font(GlassDesignSystem.Typography.bodySmall)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, GlassDesignSystem.Spacing.md)
            .padding(.bottom, GlassDesignSystem.Spacing.sm)
        }
        .padding(.top, GlassDesignSystem.Spacing.md)
    }
    
    // Weather detail item (humidity, wind, etc.)
    private func weatherDetailItem(icon: String, value: String) -> some View {
        HStack(spacing: GlassDesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            
            Text(value)
                .font(GlassDesignSystem.Typography.bodySmall)
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
        }
    }
    
    // Recommendations sheet view
    private var recommendationsView: some View {
        NavigationView {
            List {
                if let weatherData = viewModel.weatherData {
                    Section(header: Text("Weather in \(weatherData.location)")) {
                        HStack {
                            Image(systemName: viewModel.weatherIcon(for: weatherData.condition))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(getIconColor(for: weatherData.condition), Color.primary)
                            Text("\(weatherData.temperatureString), \(weatherData.condition)")
                        }
                    }
                }
                
                Section(header: Text("Recommended Outfit")) {
                    ForEach(viewModel.getClothingRecommendations(), id: \.self) { recommendation in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(recommendation)
                        }
                    }
                }
                
                Section {
                    Button("Refresh Weather") {
                        viewModel.refreshWeather()
                    }
                }
            }
            .navigationTitle("Weather Outfit Tips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingRecommendations = false
                    }
                }
            }
        }
    }
    
    // Helper function to get icon color based on weather condition
    private func getIconColor(for condition: String) -> Color {
        if condition.lowercased().contains("clear") || condition.lowercased().contains("sunny") {
            return .yellow
        } else if condition.lowercased().contains("cloud") {
            return .gray
        } else if condition.lowercased().contains("rain") || condition.lowercased().contains("drizzle") {
            return .blue
        } else if condition.lowercased().contains("snow") || condition.lowercased().contains("sleet") {
            return .cyan
        } else if condition.lowercased().contains("thunder") || condition.lowercased().contains("lightning") {
            return .yellow
        } else {
            return .gray
        }
    }
    
    // GlassBackground has been moved to its own file and enhanced with the design system
}

struct WeatherCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light mode preview with placeholder state
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                WeatherCardView()
            }
            .previewDisplayName("Light Mode")
            
            // Dark mode preview with placeholder state
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]),
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                WeatherCardView()
            }
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
            
            // Loading state preview
            loadingPreview
                .previewDisplayName("Loading State")
            
            // Error state preview
            errorPreview
                .previewDisplayName("Error State")
        }
    }
    
    // Helper computed properties for previews
    static var loadingPreview: some View {
        let loadingViewModel = WeatherViewModel()
        loadingViewModel.isLoading = true
        
        return ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            WeatherCardView(viewModel: loadingViewModel)
        }
    }
    
    static var errorPreview: some View {
        let errorViewModel = WeatherViewModel()
        errorViewModel.errorMessage = "Unable to fetch weather data"
        
        return ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            WeatherCardView(viewModel: errorViewModel)
        }
    }
}
