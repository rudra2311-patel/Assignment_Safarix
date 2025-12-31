import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for API keys
/// This class reads from .env file using flutter_dotenv
/// Note: This provides cleaner code organization but not full security
/// since this is a frontend-only app and keys can be extracted from compiled code
class Environment {
  /// OpenTripMap API Key for tourist places data
  static String get openTripMapApiKey {
    return dotenv.env['OPENTRIPMAP_API_KEY'] ?? '';
  }

  /// OpenWeatherMap API Key for weather data
  static String get openWeatherMapApiKey {
    return dotenv.env['OPENWEATHERMAP_API_KEY'] ?? '';
  }

  /// Unsplash API Key (optional) for destination images
  static String get unsplashApiKey {
    return dotenv.env['UNSPLASH_API_KEY'] ?? '';
  }

  /// Check if all required API keys are present
  static bool get hasRequiredKeys {
    return openTripMapApiKey.isNotEmpty && openWeatherMapApiKey.isNotEmpty;
  }
}
