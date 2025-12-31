import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/travel_repository.dart';
import '../../models/place_model.dart';
import '../../core/constants/app_constants.dart';
import '../map/map_viewer_screen.dart';

/// Simple Place Detail Screen
/// Shows image, distance, rating, and description
class PlaceDetailScreen extends StatefulWidget {
  final String xid;
  final String placeName;
  final TravelRepository repository;
  final double? distance; // Distance in km

  const PlaceDetailScreen({
    super.key,
    required this.xid,
    required this.placeName,
    required this.repository,
    this.distance,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  PlaceDetail? _placeDetail;
  bool _isLoading = false;
  String? _errorMessage;
  String? _imageUrl; // Cached image URL
  bool _imageLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaceDetails();
    _fetchUnsplashImage();
  }

  Future<void> _loadPlaceDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await widget.repository.getPlaceDetails(widget.xid);

      setState(() {
        _placeDetail = detail;
        _isLoading = false;
        if (detail == null) {
          _errorMessage = 'Could not load place details';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load details';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchUnsplashImage() async {
    setState(() {
      _imageLoading = true;
    });

    try {
      final query = Uri.encodeComponent(widget.placeName);
      final apiKey = dotenv.env['UNSPLASH_ACCESS_KEY'];

      if (apiKey != null && apiKey.isNotEmpty) {
        // Use official Unsplash API
        final url =
            'https://api.unsplash.com/photos/random?query=${query},landmark,travel,architecture&client_id=$apiKey&orientation=landscape';

        final response = await http
            .get(Uri.parse(url))
            .timeout(Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _imageUrl = data['urls']['regular'] ?? data['urls']['full'];
            _imageLoading = false;
          });
          return;
        }
      }

      // Fallback to free source.unsplash.com (always works)
      setState(() {
        _imageUrl =
            'https://source.unsplash.com/800x400/?${query},landmark,travel,architecture';
        _imageLoading = false;
      });
    } catch (e) {
      // Fallback on error
      final query = Uri.encodeComponent(widget.placeName);
      setState(() {
        _imageUrl =
            'https://source.unsplash.com/800x400/?${query},landmark,travel';
        _imageLoading = false;
      });
    }
  }

  String _formatDistance() {
    if (widget.distance == null) return '';
    final km = widget.distance!;
    if (km < 1) {
      return '${(km * 1000).toInt()}m away';
    }
    return '${km.toStringAsFixed(1)}km away';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.placeName),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange.shade600),
            SizedBox(height: 16),
            Text('Loading...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.orange.shade300),
            SizedBox(height: 16),
            Text(_errorMessage!, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPlaceDetails,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_placeDetail == null) {
      return Center(child: Text('No details available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildImage(), _buildContent()],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: 250,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _imageUrl != null
              ? Image.network(
                  _imageUrl!,
                  fit: BoxFit.cover,
                  // Cache images for better performance
                  cacheHeight: 400,
                  cacheWidth: 800,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.orange.shade300,
                          Colors.orange.shade600,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Image unavailable',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade100,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.orange.shade600,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.grey.shade100,
                  child: Center(
                    child: _imageLoading
                        ? CircularProgressIndicator(
                            color: Colors.orange.shade600,
                          )
                        : Icon(Icons.photo, size: 60, color: Colors.grey),
                  ),
                ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final rating = int.tryParse(_placeDetail!.rate) ?? 3;

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Distance badge
          if (widget.distance != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    _formatDistance(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          // Rating
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < (rating / 7 * 5).round()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 24,
                );
              }),
              SizedBox(width: 8),
              Text(
                '$rating/7',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Address
          if (_placeDetail!.address.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _placeDetail!.address,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],

          // Categories
          if (_placeDetail!.kinds.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _placeDetail!.kinds
                  .split(',')
                  .take(5)
                  .map(
                    (kind) => Chip(
                      label: Text(kind.trim(), style: TextStyle(fontSize: 12)),
                      backgroundColor: Colors.orange.shade50,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 20),
          ],

          // Description
          if (_placeDetail!.wikipediaExtracts != null) ...[
            Text(
              'About',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _placeDetail!.wikipediaExtracts!.text,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 20),
          ],

          // Links
          if (_placeDetail!.wikipedia.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchURL(_placeDetail!.wikipedia),
                icon: Icon(Icons.menu_book),
                label: Text('Read on Wikipedia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
          ],

          if (_placeDetail!.osm.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapViewerScreen(
                        latitude: _placeDetail!.point.lat,
                        longitude: _placeDetail!.point.lon,
                        placeName: widget.placeName,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.map),
                label: Text('View on Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
