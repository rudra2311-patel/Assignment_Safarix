import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/env.dart';
import '../core/constants/api_constants.dart';
import '../models/place_model.dart';
import 'weather_service.dart';

/// Service responsible for all OpenTripMap interactions
/// Implements proper error handling for API unavailability
class PlaceService {
  final String _openTripMapKey = Environment.openTripMapApiKey;
  final WeatherService _weatherService = WeatherService();

  /// Get geographic coordinates for a city using OpenWeatherMap
  Future<GeoName?> getGeoName(String cityName) async {
    try {
      final geocode = await _weatherService.geocodeCity(cityName);

      if (geocode == null || geocode['lat'] == null || geocode['lon'] == null) {
        print('❌ Geocoding failed for city: $cityName');
        return null;
      }

      return GeoName(
        name: geocode['name'] ?? cityName,
        country: geocode['country'] ?? '',
        lat: geocode['lat'],
        lon: geocode['lon'],
        population: 0,
        timezone: '',
        isValid: true,
      );
    } catch (e) {
      print('💥 Exception in getGeoName: $e');
      return null;
    }
  }

  /// Fetch tourist places within radius using OpenTripMap API
  /// Returns empty list if API returns no data (common with free tier)
  Future<List<Place>> getPlacesByRadius({
    required double lat,
    required double lon,
    double radius = ApiConstants.defaultRadius,
    int limit = ApiConstants.defaultPlacesLimit,
    int offset = 0,
    String kinds = ApiConstants.defaultPlaceKinds,
    String? cityName,
  }) async {
    if (lat == 0.0 || lon == 0.0) {
      print('❌ Invalid coordinates: lat=$lat lon=$lon');
      return [];
    }

    try {
      final url =
          Uri.parse(
            '${ApiConstants.openTripMapBaseUrl}${ApiConstants.radiusEndpoint}',
          ).replace(
            queryParameters: {
              'radius': radius.toString(),
              'lon': lon.toString(),
              'lat': lat.toString(),
              'apikey': _openTripMapKey,
            },
          );

      print('\n🌍 FETCHING PLACES FROM OPENTRIPMAP');
      print('📍 Coordinates: lat=$lat, lon=$lon, radius=$radius');
      print('🔗 $url');

      final response = await http.get(url);
      print('📡 Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('❌ HTTP Error: ${response.statusCode}');
        return [];
      }

      final decoded = json.decode(response.body);

      if (decoded is Map) {
        print('⚠️ OpenTripMap returned: $decoded');
        print(
          '📌 No places found - This is expected with OpenTripMap free tier',
        );
        print(
          '💡 The API endpoint is working, but database coverage is limited',
        );
        return [];
      }

      if (decoded is! List) {
        print('❌ Unexpected response type: ${decoded.runtimeType}');
        return [];
      }

      final places = decoded
          .map<Place>((json) => Place.fromJson(json))
          .toList();

      print('✅ Places found: ${places.length}');
      if (places.isNotEmpty) {
        print('📍 First place: ${places.first.name}');
      }
      return places;
    } catch (e, stackTrace) {
      print('💥 Exception in getPlacesByRadius: $e');
      print(stackTrace);
      return [];
    }
  }

  /// Fetch detailed information about a specific place
  Future<PlaceDetail?> getPlaceDetails(String xid) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.openTripMapBaseUrl}${ApiConstants.xidEndpoint}/$xid',
      ).replace(queryParameters: {'apikey': _openTripMapKey});

      print('\n📍 FETCHING PLACE DETAILS');
      print('🔗 $url');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        print('❌ Failed to load details: ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body);
      return PlaceDetail.fromJson(data);
    } catch (e) {
      print('💥 Exception in getPlaceDetails: $e');
      return null;
    }
  }
}
