import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/env.dart';
import '../core/constants/api_constants.dart';
import '../models/weather_model.dart';

/// Service for OpenWeatherMap API calls
/// Handles weather data fetching
class WeatherService {
  final String _apiKey = Environment.openWeatherMapApiKey;

  /// Fetch current weather for a city by coordinates
  Future<Weather?> getWeatherByCoordinates({
    required double lat,
    required double lon,
  }) async {
    try {
      final url =
          Uri.parse(
            '${ApiConstants.openWeatherMapBaseUrl}${ApiConstants.weatherEndpoint}',
          ).replace(
            queryParameters: {
              'lat': lat.toString(),
              'lon': lon.toString(),
              'appid': _apiKey,
              'units': 'metric', // For Celsius
            },
          );

      print('\nFETCHING WEATHER:');
      print('Location: lat=$lat, lon=$lon');
      print('URL: $url');

      final response = await http.get(url);

      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Weather data received for: ${data['name']}');
        print(
          'Temp: ${data['main']['temp']}°C, Desc: ${data['weather'][0]['description']}',
        );
        return Weather.fromJson(data);
      } else {
        print('Error fetching weather: ${response.statusCode}');
        print('Error body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception in getWeatherByCoordinates: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Fetch current weather for a city by name
  Future<Weather?> getWeatherByCityName(String cityName) async {
    try {
      final url =
          Uri.parse(
            '${ApiConstants.openWeatherMapBaseUrl}${ApiConstants.weatherEndpoint}',
          ).replace(
            queryParameters: {
              'q': cityName,
              'appid': _apiKey,
              'units': 'metric', // For Celsius
            },
          );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data);
      } else {
        print('Error fetching weather: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in getWeatherByCityName: $e');
      return null;
    }
  }

  /// Geocode city name to coordinates (FALLBACK for OpenTripMap)
  /// Returns GeoName with coordinates if city found
  Future<Map<String, dynamic>?> geocodeCity(String cityName) async {
    try {
      final url =
          Uri.parse(
            '${ApiConstants.openWeatherMapBaseUrl}${ApiConstants.weatherEndpoint}',
          ).replace(
            queryParameters: {
              'q': cityName,
              'appid': _apiKey,
              'units': 'metric',
            },
          );

      print('\nFALLBACK GEOCODING (OpenWeatherMap):');
      print('City: $cityName');
      print('URL: $url');

      final response = await http.get(url);

      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coord = data['coord'];
        print('Found coordinates: lat=${coord['lat']}, lon=${coord['lon']}');

        return {
          'name': data['name'],
          'country': data['sys']['country'] ?? '',
          'lat': coord['lat'],
          'lon': coord['lon'],
        };
      } else {
        print('Geocoding failed: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception in geocodeCity: $e');
      return null;
    }
  }

  /// Fetch 5-day weather forecast for coordinates
  Future<List<Weather>> getForecastByCoordinates({
    required double lat,
    required double lon,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.openWeatherMapBaseUrl}/forecast')
          .replace(
            queryParameters: {
              'lat': lat.toString(),
              'lon': lon.toString(),
              'appid': _apiKey,
              'units': 'metric',
              'cnt': '40', // 5 days * 8 (3-hour intervals)
            },
          );

      print('\nFETCHING FORECAST:');
      print('Location: lat=$lat, lon=$lon');
      print('URL: $url');

      final response = await http.get(url);
      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cityName = data['city']['name'] ?? '';
        final list = data['list'] as List;

        print('Forecast data received: ${list.length} entries for $cityName');

        return list.map((item) {
          return Weather.fromJson({...item, 'name': cityName});
        }).toList();
      } else {
        print('Error fetching forecast: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      print('Exception in getForecastByCoordinates: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
}
