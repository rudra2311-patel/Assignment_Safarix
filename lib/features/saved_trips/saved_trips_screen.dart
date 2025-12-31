import 'package:flutter/material.dart';
import '../../data/travel_repository.dart';
import '../../models/saved_trip_model.dart';
import '../../services/local_storage_service.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/connectivity_banner.dart';
import '../itinerary/itinerary_screen.dart';
import 'widgets/trip_card.dart';

/// Saved Trips Screen - Offline access to saved trips
/// Displays all locally saved trips with last updated timestamps
class SavedTripsScreen extends StatefulWidget {
  final TravelRepository repository;

  const SavedTripsScreen({super.key, required this.repository});

  @override
  State<SavedTripsScreen> createState() => _SavedTripsScreenState();
}

class _SavedTripsScreenState extends State<SavedTripsScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  List<SavedTrip> _trips = [];
  bool _isLoading = false;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _checkConnectivity();
  }

  Future<void> _loadTrips() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _storageService.initialize();
      final trips = _storageService.getAllTrips();

      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error loading trips: $e');
    }
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await widget.repository.hasInternetConnection();
    setState(() {
      _hasInternet = hasConnection;
    });
  }

  Future<void> _deleteTrip(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Trip'),
        content: Text('Are you sure you want to delete this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.deleteTrip(id);
      await _loadTrips();
      _showSnackBar('Trip deleted');
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
        title: Text('Saved Trips'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          if (_trips.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: _confirmClearAll,
            ),
        ],
      ),
      body: Column(
        children: [
          // Connectivity Status
          ConnectivityBanner(
            isOffline: !_hasInternet,
            message: 'Offline mode - Viewing saved trips',
          ),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return LoadingIndicator(message: 'Loading saved trips...');
    }

    if (_trips.isEmpty) {
      return EmptyState(
        icon: Icons.bookmark_border,
        message:
            'No saved trips yet!\nCreate your first itinerary to get started.',
        actionLabel: 'Explore Destinations',
        onAction: () => Navigator.pop(context),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _trips.length,
        itemBuilder: (context, index) {
          final trip = _trips[index];
          return TripCard(
            trip: trip,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ItineraryScreen(trip: trip, repository: widget.repository),
              ),
            ),
            onDelete: () => _deleteTrip(trip.id),
          );
        },
      ),
    );
  }

  Future<void> _confirmClearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Trips'),
        content: Text('Are you sure you want to delete all saved trips?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.clearAllTrips();
      await _loadTrips();
      _showSnackBar('All trips deleted');
    }
  }
}
