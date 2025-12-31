import 'package:hive/hive.dart';
import 'place_model.dart';
import 'weather_model.dart';

part 'saved_trip_model.g.dart';

/// Model for a saved trip (stored locally for offline access)
@HiveType(typeId: 0)
class SavedTrip extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cityName;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final List<String> selectedPlaceIds;

  @HiveField(5)
  final Map<String, dynamic> weatherSnapshot;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime lastUpdated;

  @HiveField(8)
  final List<Map<String, dynamic>> placesData;

  SavedTrip({
    required this.id,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.selectedPlaceIds,
    required this.weatherSnapshot,
    required this.createdAt,
    required this.lastUpdated,
    required this.placesData,
  });

  /// Create from city, places, and weather
  factory SavedTrip.create({
    required String cityName,
    required double latitude,
    required double longitude,
    required List<Place> places,
    required Weather weather,
  }) {
    final now = DateTime.now();
    return SavedTrip(
      id: '${cityName}_${now.millisecondsSinceEpoch}',
      cityName: cityName,
      latitude: latitude,
      longitude: longitude,
      selectedPlaceIds: places.map((p) => p.xid).toList(),
      weatherSnapshot: weather.toJson(),
      createdAt: now,
      lastUpdated: now,
      placesData: places.map((p) => p.toJson()).toList(),
    );
  }

  /// Get weather from snapshot
  Weather get weather => Weather.fromJson(weatherSnapshot);

  /// Get places from data
  List<Place> get places =>
      placesData.map((data) => Place.fromJson(data)).toList();

  /// Get formatted last updated time
  String get lastUpdatedFormatted {
    final now = DateTime.now();
    final diff = now.difference(lastUpdated);

    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
