# Safarix - Travel Companion

A Flutter-based mobile application that helps travelers discover tourist attractions, view detailed information, and explore places on interactive maps. Built with clean architecture principles and modern Flutter practices.

## Overview

Safarix is a travel discovery app that integrates multiple APIs to provide users with comprehensive information about tourist destinations worldwide. Users can search for any city, view nearby attractions, check weather conditions, and explore places through an integrated map interface.

## Features

- **City Search**: Search for any city worldwide with real-time geocoding
- **Tourist Attractions**: Discover nearby museums, monuments, parks, and historic sites
- **Place Details**: View detailed information including:
  - High-quality images from Unsplash
  - Distance from city center
  - Ratings and descriptions
  - Address and categories
  - Wikipedia links
- **In-App Map**: Interactive OpenStreetMap integration via WebView
- **Weather Information**: Current weather conditions for searched locations
- **Offline Support**: Caching for better performance and offline access

## Technology Stack

### Frontend
- **Flutter** (v3.9.2+) - Cross-platform mobile framework
- **Dart** - Programming language

### Backend Services
- **OpenStreetMap Overpass API** - Primary source for tourist attractions
- **OpenTripMap API** - Fallback for place data
- **OpenWeatherMap API** - Weather information and geocoding
- **Unsplash API** - High-quality place images

### Architecture & Patterns
- **Repository Pattern** - Data layer abstraction
- **Provider State Management** - Simple and efficient state handling
- **Service Layer** - Separation of business logic
- **Clean Architecture** - Organized code structure

### Key Packages
- `http` - API calls
- `hive` - Local database for caching
- `shared_preferences` - Persistent storage
- `flutter_dotenv` - Environment variables management
- `webview_flutter` - In-app map viewer
- `url_launcher` - External link handling
- `connectivity_plus` - Network connectivity check

## Architecture

[Add your Excalidraw architecture diagram here]

### Project Structure

```
lib/
├── core/
│   ├── constants/        # App-wide constants
│   ├── network/          # Base API service
│   ├── utils/            # Logger and utilities
│   └── widgets/          # Reusable UI components
├── data/
│   └── travel_repository.dart  # Main data repository
├── features/
│   ├── auth/             # Login screen
│   ├── home/             # Home and search
│   ├── places/           # Places list view
│   ├── place_details/    # Detailed place info
│   └── map/              # Map viewer
├── models/               # Data models
├── services/             # API services
│   ├── place_service.dart
│   ├── weather_service.dart
│   └── overpass_service.dart
└── main.dart             # App entry point
```

### Data Flow

1. User searches for a city
2. Weather service geocodes the city name
3. Repository fetches places from Overpass API (primary) or OpenTripMap (fallback)
4. Places are cached locally using Hive
5. User selects a place to view details
6. Unsplash API fetches relevant images
7. User can view location on integrated map

## Setup Instructions

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device

### 1. Clone the Repository

```bash
git clone https://github.com/rudra2311-patel/Assignment_Safarix.git
cd safarix
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API Keys

Create a `.env` file in the root directory :

Add your API keys to the `.env` file:

```env
OPENTRIPMAP_API_KEY=your_key_here
OPENWEATHERMAP_API_KEY=your_key_here
UNSPLASH_ACCESS_KEY=your_key_here
UNSPLASH_SECRET_KEY=your_key_here
```

#### Where to Get API Keys:

- **OpenTripMap**: https://opentripmap.io/product (Free tier available)
- **OpenWeatherMap**: https://openweathermap.org/api (Free tier available)
- **Unsplash**: https://unsplash.com/developers (Free tier: 50 requests/hour)

### 4. Run the App

```bash
flutter run
```

Or use your IDE's run button.

## How to Use

1. **Launch the App**: Open Safarix on your device
2. **Search for a City**: Enter any city name (e.g., "Paris", "Tokyo", "New York")
3. **Browse Attractions**: Scroll through the list of nearby tourist spots
4. **View Details**: Tap any place to see:
   - Beautiful high-resolution images
   - Distance from city center
   - Ratings and descriptions
   - Categories and address
5. **Explore on Map**: Click "View on Map" to see the location on OpenStreetMap
6. **Read More**: Click "Read on Wikipedia" for detailed information

## Screenshots

[Add your app screenshots here]

### Home Screen
[Screenshot of home/search screen]

### Places List
[Screenshot showing list of tourist attractions]

### Place Details
[Screenshot of detailed place view with image]

### Map View
[Screenshot of integrated map]

## Known Limitations

- Overpass API can be slow during peak hours (10+ seconds)
- OpenTripMap free tier has limited coverage for some cities
- Unsplash free tier limited to 50 requests/hour
- Requires active internet connection for initial data fetch

## Future Enhancements

- Add favorites and trip planning
- Implement user authentication
- Add reviews and ratings
- Offline mode with pre-cached data
- Multi-language support
- Route planning between attractions

## Testing

Run tests with:

```bash
flutter test
```

## Build for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Author

Developed by Rudra Patel

## Acknowledgments

- OpenStreetMap contributors for geographic data
- Unsplash photographers for beautiful images
- OpenWeatherMap for weather data
- Flutter team for the amazing framework
