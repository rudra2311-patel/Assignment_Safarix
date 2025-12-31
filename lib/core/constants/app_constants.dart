/// App-wide constants
class AppConstants {
  // App Information
  static const String appName = 'Safarix';
  static const String appTagline = 'Your Smart Travel Companion';

  // Storage keys
  static const String savedTripsKey = 'saved_trips';
  static const String lastUpdatedKey = 'last_updated';

  // Error messages
  static const String noInternetError =
      'No internet connection. Showing saved data.';
  static const String apiError = 'Failed to fetch data. Please try again.';
  static const String emptyPlacesMessage =
      'No tourist places found for this location.';
  static const String emptyTripsMessage =
      'No saved trips yet. Start exploring!';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const int maxRetries = 3;

  // Popular cities that work well with OpenTripMap API
  static const List<String> popularCities = [
    'Mumbai',
    'Paris',
    'London',
    'Tokyo',
    'Rome',
    'Barcelona',
    'Amsterdam',
    'Berlin',
    'Prague',
    'Vienna',
  ];
}
