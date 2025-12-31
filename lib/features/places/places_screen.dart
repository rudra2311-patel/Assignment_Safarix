import 'package:flutter/material.dart';
import '../../data/travel_repository.dart';
import '../../models/place_model.dart';
import '../../models/weather_model.dart';
import '../../models/saved_trip_model.dart';
import '../../services/local_storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/api_constants.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/error_view.dart';
import '../place_details/place_detail_screen.dart';
import '../itinerary/itinerary_screen.dart';
import 'widgets/place_card.dart';
import 'widgets/weather_card.dart';

/// Places List Screen with pagination support
/// Displays tourist places for a selected city
class PlacesScreen extends StatefulWidget {
  final GeoName geoName;
  final TravelRepository repository;

  const PlacesScreen({
    super.key,
    required this.geoName,
    required this.repository,
  });

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final ScrollController _scrollController = ScrollController();
  final LocalStorageService _storageService = LocalStorageService();

  List<Place> _places = [];
  Weather? _weather;

  bool _isLoadingPlaces = false;
  bool _isLoadingMore = false;
  bool _hasMorePlaces = true;

  String? _errorMessage;
  int _currentOffset = 0;

  final Set<String> _selectedPlaceIds = {};

  @override
  void initState() {
    super.initState();
    _initializeStorage();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initializeStorage() async {
    await _storageService.initialize();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadPlaces(), _loadWeather()]);
  }

  Future<void> _loadPlaces() async {
    if (_isLoadingPlaces) return;

    setState(() {
      _isLoadingPlaces = true;
      _errorMessage = null;
    });

    try {
      final places = await widget.repository.getPlacesByRadius(
        lat: widget.geoName.lat,
        lon: widget.geoName.lon,
        radius: ApiConstants.defaultRadius,
        limit: ApiConstants.defaultPlacesLimit,
        offset: _currentOffset,
        cityName: widget.geoName.name,
      );

      setState(() {
        if (places.isEmpty) {
          _hasMorePlaces = false;
          if (_places.isEmpty) {
            _errorMessage = AppConstants.emptyPlacesMessage;
          }
        } else {
          _places.addAll(places);
          _currentOffset += places.length;
        }
        _isLoadingPlaces = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = AppConstants.apiError;
        _isLoadingPlaces = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMorePlaces) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final places = await widget.repository.getPlacesByRadius(
        lat: widget.geoName.lat,
        lon: widget.geoName.lon,
        radius: ApiConstants.defaultRadius,
        limit: ApiConstants.defaultPlacesLimit,
        offset: _currentOffset,
        cityName: widget.geoName.name,
      );

      setState(() {
        if (places.isEmpty) {
          _hasMorePlaces = false;
        } else {
          _places.addAll(places);
          _currentOffset += places.length;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showSnackBar('Failed to load more places');
    }
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await widget.repository.getWeather(
        lat: widget.geoName.lat,
        lon: widget.geoName.lon,
        cityName: widget.geoName.name,
      );

      setState(() {
        _weather = weather;
      });
    } catch (e) {
      // Weather is optional, silently fail
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadMore();
    }
  }

  void _togglePlaceSelection(String xid) {
    setState(() {
      if (_selectedPlaceIds.contains(xid)) {
        _selectedPlaceIds.remove(xid);
      } else {
        _selectedPlaceIds.add(xid);
      }
    });
  }

  Future<void> _saveTrip() async {
    if (_selectedPlaceIds.isEmpty) {
      _showSnackBar('Please select at least one place');
      return;
    }

    if (_weather == null) {
      _showSnackBar('Weather data not available');
      return;
    }

    final selectedPlaces = _places
        .where((place) => _selectedPlaceIds.contains(place.xid))
        .toList();

    final trip = SavedTrip.create(
      cityName: widget.geoName.name,
      latitude: widget.geoName.lat,
      longitude: widget.geoName.lon,
      places: selectedPlaces,
      weather: _weather!,
    );

    await _storageService.saveTrip(trip);

    if (mounted) {
      _showSnackBar('Trip saved successfully!');
      // Navigate to itinerary
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ItineraryScreen(trip: trip, repository: widget.repository),
        ),
      );
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
        title: Text(widget.geoName.name),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedPlaceIds.isNotEmpty)
            TextButton.icon(
              onPressed: _saveTrip,
              icon: Icon(Icons.save, color: Colors.white),
              label: Text(
                '${_selectedPlaceIds.length}',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _currentOffset = 0;
          _places.clear();
          _hasMorePlaces = true;
          await _loadInitialData();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Weather Card
            if (_weather != null)
              SliverToBoxAdapter(
                child: WeatherCard(
                  weather: _weather!,
                  latitude: widget.geoName.lat,
                  longitude: widget.geoName.lon,
                ),
              ),

            // Loading Indicator
            if (_isLoadingPlaces && _places.isEmpty)
              SliverFillRemaining(
                child: LoadingIndicator(message: 'Loading places...'),
              ),

            // Error Message
            if (_errorMessage != null && _places.isEmpty)
              SliverFillRemaining(
                child: ErrorView(
                  message: _errorMessage!,
                  onRetry: () {
                    _currentOffset = 0;
                    _places.clear();
                    _loadInitialData();
                  },
                ),
              ),

            // Places List
            if (_places.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.all(AppConstants.defaultPadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final place = _places[index];
                    final isSelected = _selectedPlaceIds.contains(place.xid);
                    return PlaceCard(
                      place: place,
                      isSelected: isSelected,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaceDetailScreen(
                            xid: place.xid,
                            placeName: place.name,
                            repository: widget.repository,
                            distance: place.dist, // Pass distance
                          ),
                        ),
                      ),
                      onCheckboxChanged: () => _togglePlaceSelection(place.xid),
                    );
                  }, childCount: _places.length),
                ),
              ),

            // Load More Indicator
            if (_isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            // End of List
            if (!_hasMorePlaces && _places.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No more places to load',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _selectedPlaceIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _saveTrip,
              backgroundColor: Colors.orange.shade600,
              icon: Icon(Icons.map),
              label: Text('Create Itinerary'),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
