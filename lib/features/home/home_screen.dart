import 'package:flutter/material.dart';
import '../../data/travel_repository.dart';
import '../../services/place_service.dart';
import '../../services/weather_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/connectivity_service.dart';
import '../../core/constants/app_constants.dart';
import '../places/places_screen.dart';
import '../saved_trips/saved_trips_screen.dart';

/// Home Screen with city search functionality
/// User can search for destinations and navigate to places
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late TravelRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _checkConnectivity();
  }

  void _initializeRepository() {
    _repository = TravelRepository(
      placeService: PlaceService(),
      weatherService: WeatherService(),
      storageService: LocalStorageService(),
      connectivityService: ConnectivityService(),
    );
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await _repository.hasInternetConnection();
    setState(() {
      _hasInternet = hasConnection;
    });
  }

  Future<void> _searchCity() async {
    final cityName = _searchController.text.trim();

    if (cityName.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a city name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check connectivity
      final hasConnection = await _repository.hasInternetConnection();

      if (!hasConnection) {
        setState(() {
          _isLoading = false;
          _hasInternet = false;
          _errorMessage = AppConstants.noInternetError;
        });

        // Show saved trips instead
        _showSnackBar('No internet. Showing saved trips.');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SavedTripsScreen(repository: _repository),
          ),
        );
        return;
      }

      // Get geoname (coordinates)
      final geoName = await _repository.getGeoName(cityName);

      if (geoName == null) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'City "$cityName" not found.\n\nTry:\n• Full city name (e.g., "New Delhi" instead of "Delhi")\n• Capital cities (Mumbai, Paris, London)\n• Different spelling';
        });
        return;
      }

      // Navigate to places screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PlacesScreen(geoName: geoName, repository: _repository),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SavedTripsScreen(repository: _repository),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Discover Your Next Adventure',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.appTagline,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Connectivity Indicator
              if (!_hasInternet)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.orange.shade800),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Offline mode - Access your saved trips',
                          style: TextStyle(color: Colors.orange.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!_hasInternet) const SizedBox(height: 16),

              // Search Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.cardBorderRadius,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Enter City Name',
                          hintText: 'e.g., Mumbai, Delhi, Jaipur',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSubmitted: (_) => _searchCity(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _searchCity,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Search Destination',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade800),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Popular Suggestions
              Text(
                'Popular Destinations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSuggestionChip('Mumbai'),
                  _buildSuggestionChip('Delhi'),
                  _buildSuggestionChip('Jaipur'),
                  _buildSuggestionChip('Goa'),
                  _buildSuggestionChip('Bangalore'),
                  _buildSuggestionChip('Kolkata'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String city) {
    return ActionChip(
      label: Text(city),
      onPressed: () {
        _searchController.text = city;
        _searchCity();
      },
      backgroundColor: Colors.orange.shade50,
      side: BorderSide(color: Colors.orange.shade200),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
