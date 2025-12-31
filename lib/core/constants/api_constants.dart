/// API endpoints configuration
class ApiConstants {
  // Base URLs
  static const String openTripMapBaseUrl =
      'https://api.opentripmap.com/0.1/en/places';
  static const String openWeatherMapBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const String unsplashBaseUrl = 'https://api.unsplash.com';

  // OpenTripMap endpoints
  static const String geonameEndpoint = '/geoname';
  static const String radiusEndpoint = '/radius';
  static const String xidEndpoint = '/xid';

  // OpenWeatherMap endpoints
  static const String weatherEndpoint = '/weather';

  // Default search parameters
  static const double defaultRadius =
      10000; // 10km radius - broader search area
  static const int defaultPlacesLimit = 50; // More results
  static const String defaultPlaceKinds =
      'interesting_places'; // Default category only
}
