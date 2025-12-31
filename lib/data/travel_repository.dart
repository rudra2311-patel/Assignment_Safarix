import '../models/place_model.dart';
import '../models/weather_model.dart';
import '../services/place_service.dart';
import '../services/overpass_service.dart';
import '../core/utils/logger.dart';
import '../services/weather_service.dart';
import '../services/connectivity_service.dart';
import '../services/local_storage_service.dart';

/// Repository that abstracts data source (API vs local cache)
/// Decides whether to fetch from remote API or use cached local data
/// Uses Overpass API (OSM) as PRIMARY source, OpenTripMap as fallback
class TravelRepository {
  final PlaceService _placeService; // OpenTripMap (kept for demonstration)
  final OverpassService _overpassService; // PRIMARY source
  final WeatherService _weatherService;
  final LocalStorageService _storageService;
  final ConnectivityService _connectivityService;

  TravelRepository({
    required PlaceService placeService,
    required WeatherService weatherService,
    required LocalStorageService storageService,
    required ConnectivityService connectivityService,
    OverpassService? overpassService,
  }) : _placeService = placeService,
       _overpassService = overpassService ?? OverpassService(),
       _weatherService = weatherService,
       _storageService = storageService,
       _connectivityService = connectivityService;

  /// Get geoname with offline fallback
  Future<GeoName?> getGeoName(String cityName) async {
    final hasInternet = await _connectivityService.hasConnection();

    if (hasInternet) {
      // Try to fetch from API
      final geoName = await _placeService.getGeoName(cityName);
      return geoName;
    } else {
      // Check if we have cached trips for this city
      final trips = _storageService.getTripsForCity(cityName);
      if (trips.isNotEmpty) {
        final trip = trips.first;
        return GeoName(
          name: trip.cityName,
          country: '',
          lat: trip.latitude,
          lon: trip.longitude,
          population: 0,
          timezone: '',
        );
      }
      return null;
    }
  }

  /// Get places by radius with caching support
  /// PRIMARY: Uses Overpass API (OpenStreetMap)
  /// FALLBACK: Uses OpenTripMap if Overpass fails
  Future<List<Place>> getPlacesByRadius({
    required double lat,
    required double lon,
    double radius = 5000,
    int limit = 20,
    int offset = 0,
    String? cityName,
  }) async {
    final hasInternet = await _connectivityService.hasConnection();

    if (!hasInternet) {
      Logger.warn('No internet connection');
      return [];
    }

    // TRY 1: Overpass API (PRIMARY - reliable, free, no API key)
    Logger.info('Attempting Overpass API', 'Repository');
    try {
      final places = await _overpassService.getPlacesByRadius(
        lat: lat,
        lon: lon,
        radiusInKm: radius / 1000, // Convert meters to km
        limit: limit,
      );

      if (places.isNotEmpty) {
        Logger.info(
          'Retrieved ${places.length} places from Overpass',
          'Repository',
        );
        return places;
      }
      Logger.warn('Overpass returned no places');
    } catch (e) {
      Logger.error('Overpass API failed', e);
    }

    // TRY 2: OpenTripMap (FALLBACK - for demonstration)
    Logger.info('Attempting OpenTripMap API fallback', 'Repository');
    try {
      final places = await _placeService.getPlacesByRadius(
        lat: lat,
        lon: lon,
        radius: radius,
        limit: limit,
        cityName: cityName,
      );

      if (places.isNotEmpty) {
        Logger.info(
          'Retrieved ${places.length} places from OpenTripMap',
          'Repository',
        );
        return places;
      }
      Logger.warn('OpenTripMap returned no places');
    } catch (e) {
      Logger.error('OpenTripMap API failed', e);
    }

    Logger.warn('Both APIs returned no data');
    return [];
  }

  /// Get place details - tries both services
  Future<PlaceDetail?> getPlaceDetails(String xid) async {
    Logger.info('Getting details for xid=$xid', 'Repository');

    // Check if it's an OSM place (from Overpass)
    if (xid.startsWith('osm_')) {
      Logger.info('Detected OSM place, routing to Overpass', 'Repository');
      final details = await _overpassService.getPlaceDetails(xid);
      if (details != null) {
        Logger.info('Retrieved details from Overpass', 'Repository');
        return details;
      }
      Logger.warn('Overpass failed, trying OpenTripMap fallback');
    } else {
      Logger.info('Detected OpenTripMap place', 'Repository');
    }

    // Try OpenTripMap
    return await _placeService.getPlaceDetails(xid);
  }

  /// Get weather with fallback to cached data
  Future<Weather?> getWeather({
    required double lat,
    required double lon,
    String? cityName,
  }) async {
    final hasInternet = await _connectivityService.hasConnection();

    if (hasInternet) {
      return await _weatherService.getWeatherByCoordinates(lat: lat, lon: lon);
    } else {
      // Try to get from cached trips
      if (cityName != null) {
        final trips = _storageService.getTripsForCity(cityName);
        if (trips.isNotEmpty) {
          return trips.first.weather;
        }
      }
      return null;
    }
  }

  /// Check internet connectivity
  Future<bool> hasInternetConnection() async {
    return await _connectivityService.hasConnection();
  }
}
