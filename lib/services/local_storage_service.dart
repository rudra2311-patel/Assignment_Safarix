import 'package:hive_flutter/hive_flutter.dart';
import '../models/saved_trip_model.dart';

/// Service for local data storage using Hive
/// Handles saving and retrieving trips for offline access
class LocalStorageService {
  static const String _tripsBoxName = 'saved_trips';
  Box<SavedTrip>? _tripsBox;

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SavedTripAdapter());
    }

    // Open boxes
    _tripsBox = await Hive.openBox<SavedTrip>(_tripsBoxName);
  }

  /// Save a trip locally
  Future<void> saveTrip(SavedTrip trip) async {
    if (_tripsBox == null) {
      throw Exception('LocalStorageService not initialized');
    }
    await _tripsBox!.put(trip.id, trip);
  }

  /// Get all saved trips
  List<SavedTrip> getAllTrips() {
    if (_tripsBox == null) {
      throw Exception('LocalStorageService not initialized');
    }
    return _tripsBox!.values.toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
  }

  /// Get a specific trip by ID
  SavedTrip? getTripById(String id) {
    if (_tripsBox == null) {
      throw Exception('LocalStorageService not initialized');
    }
    return _tripsBox!.get(id);
  }

  /// Delete a trip
  Future<void> deleteTrip(String id) async {
    if (_tripsBox == null) {
      throw Exception('LocalStorageService not initialized');
    }
    await _tripsBox!.delete(id);
  }

  /// Check if a trip exists for a city
  bool hasTripForCity(String cityName) {
    if (_tripsBox == null) return false;
    return _tripsBox!.values.any(
      (trip) => trip.cityName.toLowerCase() == cityName.toLowerCase(),
    );
  }

  /// Get trips for a specific city
  List<SavedTrip> getTripsForCity(String cityName) {
    if (_tripsBox == null) return [];
    return _tripsBox!.values
        .where((trip) => trip.cityName.toLowerCase() == cityName.toLowerCase())
        .toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
  }

  /// Clear all trips
  Future<void> clearAllTrips() async {
    if (_tripsBox == null) {
      throw Exception('LocalStorageService not initialized');
    }
    await _tripsBox!.clear();
  }

  /// Close boxes (call when app is closing)
  Future<void> close() async {
    await _tripsBox?.close();
  }
}
