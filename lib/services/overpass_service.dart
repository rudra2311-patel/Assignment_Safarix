import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/place_model.dart';
import '../core/utils/logger.dart';

/// Service for OpenStreetMap Overpass API
/// Primary solution for point of interest fetching
class OverpassService {
  static const String _baseUrl = 'https://overpass-api.de/api/interpreter';
  static const int _timeoutSeconds = 20;

  /// Fetch tourist places using Overpass API
  Future<List<Place>> getPlacesByRadius({
    required double lat,
    required double lon,
    double radiusInKm = 3.0,
    int limit = 50,
  }) async {
    Logger.info(
      'Fetching places near ($lat, $lon), radius: ${radiusInKm}km',
      'Overpass',
    );

    try {
      final radiusInMeters = (radiusInKm * 1000).toInt();
      final query = _buildTouristQuery(lat, lon, radiusInMeters);

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {'Content-Type': 'text/plain; charset=utf-8'},
            body: query,
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List<dynamic>? ?? [];

        final places = elements
            .map((element) => _parseOsmElement(element, lat, lon))
            .where((place) => place != null)
            .cast<Place>()
            .take(limit)
            .toList();

        Logger.info('Found ${places.length} valid places', 'Overpass');
        return places;
      } else {
        Logger.warn('HTTP error ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to fetch places', e, stackTrace);
      return [];
    }
  }

  /// Build Overpass QL query for tourist places
  /// Searches for: attractions, museums, historic sites, parks
  String _buildTouristQuery(double lat, double lon, int radiusMeters) {
    return '''
[out:json][timeout:12];
(
  node["tourism"="attraction"](around:$radiusMeters,$lat,$lon);
  way["tourism"="attraction"](around:$radiusMeters,$lat,$lon);
  relation["tourism"="attraction"](around:$radiusMeters,$lat,$lon);
  
  node["tourism"="museum"](around:$radiusMeters,$lat,$lon);
  way["tourism"="museum"](around:$radiusMeters,$lat,$lon);
  relation["tourism"="museum"](around:$radiusMeters,$lat,$lon);
  
  node["historic"="monument"](around:$radiusMeters,$lat,$lon);
  way["historic"="monument"](around:$radiusMeters,$lat,$lon);
  relation["historic"="monument"](around:$radiusMeters,$lat,$lon);
  
  node["historic"="castle"](around:$radiusMeters,$lat,$lon);
  way["historic"="castle"](around:$radiusMeters,$lat,$lon);
  
  node["amenity"="place_of_worship"](around:$radiusMeters,$lat,$lon);
  way["amenity"="place_of_worship"](around:$radiusMeters,$lat,$lon);
  
  node["leisure"="park"](around:$radiusMeters,$lat,$lon);
  way["leisure"="park"](around:$radiusMeters,$lat,$lon);
);
out center 30;
''';
  }

  /// Parse OSM element to Place model
  Place? _parseOsmElement(
    Map<String, dynamic> element,
    double searchLat,
    double searchLon,
  ) {
    try {
      final tags = element['tags'] as Map<String, dynamic>? ?? {};
      final name = tags['name'] as String?;

      // Skip unnamed places
      if (name == null || name.isEmpty) {
        return null;
      }

      // Get coordinates (nodes have lat/lon, ways/relations have center)
      double? lat;
      double? lon;

      if (element['type'] == 'node') {
        lat = element['lat'] as double?;
        lon = element['lon'] as double?;
      } else {
        final center = element['center'] as Map<String, dynamic>?;
        if (center != null) {
          lat = center['lat'] as double?;
          lon = center['lon'] as double?;
        }
      }

      if (lat == null || lon == null) {
        return null;
      }

      // Calculate distance
      final distance = _calculateDistance(searchLat, searchLon, lat, lon);

      // Determine kind/category
      final kind = _determineKind(tags);

      // Create unique ID
      final xid = 'osm_${element['type']}_${element['id']}';

      return Place(
        xid: xid,
        name: name,
        kinds: kind,
        dist: distance,
        point: Point(lat: lat, lon: lon),
      );
    } catch (e) {
      print('Error parsing OSM element: $e');
      return null;
    }
  }

  /// Determine place kind/category from OSM tags
  String _determineKind(Map<String, dynamic> tags) {
    if (tags.containsKey('tourism')) {
      final tourism = tags['tourism'];
      if (tourism == 'attraction') return 'tourist_attractions';
      if (tourism == 'museum') return 'museums';
      return 'tourism';
    }

    if (tags.containsKey('historic')) {
      final historic = tags['historic'];
      if (historic == 'monument') return 'monuments';
      if (historic == 'castle') return 'castles';
      return 'historic_architecture';
    }

    if (tags.containsKey('amenity')) {
      final amenity = tags['amenity'];
      if (amenity == 'place_of_worship') return 'religion';
      return 'interesting_places';
    }

    if (tags.containsKey('leisure')) {
      final leisure = tags['leisure'];
      if (leisure == 'park') return 'parks';
      return 'natural';
    }

    return 'interesting_places';
  }

  /// Calculate distance between two points (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180.0;

  /// Fetch detailed information about a place
  Future<PlaceDetail?> getPlaceDetails(String xid) async {
    // For OSM places, we need to fetch full details
    if (!xid.startsWith('osm_')) {
      return null;
    }

    try {
      // Extract OSM type and ID from xid
      final parts = xid.split('_');
      if (parts.length != 3) return null;

      final osmType = parts[1]; // node, way, or relation
      final osmId = parts[2];

      final query =
          '''
[out:json];
$osmType($osmId);
out body;
''';

      Logger.info('Fetching OSM details for: $osmType/$osmId', 'Overpass');

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {'Content-Type': 'text/plain; charset=utf-8'},
            body: query,
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List<dynamic>? ?? [];

        if (elements.isEmpty) {
          Logger.warn('No elements found in OSM response');
          return null;
        }

        final element = elements[0];
        final tags = element['tags'] as Map<String, dynamic>? ?? {};
        Logger.info('Found OSM element with ${tags.length} tags', 'Overpass');

        // Get coordinates
        double? lat;
        double? lon;

        if (element['type'] == 'node') {
          lat = element['lat'] as double?;
          lon = element['lon'] as double?;
        } else {
          final center = element['center'] as Map<String, dynamic>?;
          if (center != null) {
            lat = center['lat'] as double?;
            lon = center['lon'] as double?;
          }
        }

        if (lat == null || lon == null) return null;

        // Build address string
        final addressParts = <String>[];
        if (tags['addr:street'] != null)
          addressParts.add(tags['addr:street'].toString());
        if (tags['addr:city'] != null)
          addressParts.add(tags['addr:city'].toString());
        if (tags['addr:country'] != null)
          addressParts.add(tags['addr:country'].toString());
        final addressStr = addressParts.join(', ');

        // Get place name
        final placeName = tags['name'] as String? ?? 'Unknown Place';

        // Get Wikipedia URL if available
        String? wikipediaUrl = tags['wikipedia'] as String?;
        if (wikipediaUrl != null && wikipediaUrl.isNotEmpty) {
          // Convert format like "en:Article_Name" to full URL
          if (wikipediaUrl.contains(':')) {
            final parts = wikipediaUrl.split(':');
            wikipediaUrl = 'https://${parts[0]}.wikipedia.org/wiki/${parts[1]}';
          }
        }

        // Build simple description from OSM tags
        final description = _buildDescription(tags);

        return PlaceDetail(
          xid: xid,
          name: placeName,
          address: addressStr.isEmpty ? 'Address not available' : addressStr,
          rate: _calculateRating(tags),
          kinds: _determineKind(tags),
          point: Point(lat: lat, lon: lon),
          wikipedia: wikipediaUrl ?? '',
          image: '', // Images handled by Unsplash in UI
          osm: 'https://www.openstreetmap.org/$osmType/$osmId',
          wikidata: tags['wikidata'] as String? ?? '',
          otm: '',
          preview: null, // No preview, using Unsplash
          wikipediaExtracts: description.isNotEmpty
              ? WikipediaExtracts(
                  title: placeName,
                  text: description,
                  html: '<p>$description</p>',
                )
              : null,
        );
      }
    } catch (e) {
      Logger.error('Failed to fetch OSM details', e);
    }

    return null;
  }

  /// Fetch Wikipedia content by article URL
  /// Build description from OSM tags
  String _buildDescription(Map<String, dynamic> tags) {
    final parts = <String>[];

    if (tags.containsKey('description')) {
      parts.add(tags['description'].toString());
    }

    // Add heritage information
    if (tags.containsKey('heritage')) {
      parts.add('Heritage Site: ${tags['heritage']}');
    }

    if (tags.containsKey('unesco')) {
      parts.add('UNESCO World Heritage Site');
    }

    // Type information
    if (tags.containsKey('tourism')) {
      final type = tags['tourism'].toString().replaceAll('_', ' ');
      parts.add('Type: ${type[0].toUpperCase()}${type.substring(1)}');
    }

    if (tags.containsKey('historic')) {
      final historic = tags['historic'].toString().replaceAll('_', ' ');
      parts.add(
        'Historic: ${historic[0].toUpperCase()}${historic.substring(1)}',
      );
    }

    // Contact information
    if (tags.containsKey('website')) {
      parts.add('Website: ${tags['website']}');
    }

    if (tags.containsKey('phone')) {
      parts.add('Phone: ${tags['phone']}');
    }

    // Opening hours
    if (tags.containsKey('opening_hours')) {
      parts.add('Hours: ${tags['opening_hours']}');
    }

    if (parts.isEmpty) {
      return 'A point of interest discovered through OpenStreetMap. This location is part of the global crowdsourced geographic database.';
    }

    return parts.join('\n\n');
  }

  /// Calculate rating based on OSM tags (out of 7)
  String _calculateRating(Map<String, dynamic> tags) {
    int score = 3; // Base score

    // UNESCO World Heritage Site = highest rating
    if (tags.containsKey('unesco') || tags['heritage:operator'] == 'unesco') {
      return '7'; // Maximum rating
    }

    // National heritage sites
    if (tags.containsKey('heritage')) {
      score += 2;
    }

    // Popular tourism categories
    if (tags['tourism'] == 'museum' || tags['tourism'] == 'attraction') {
      score += 1;
    }

    // Historic importance
    if (tags['historic'] == 'castle' || tags['historic'] == 'monument') {
      score += 1;
    }

    // Has Wikipedia article = well-documented
    if (tags.containsKey('wikipedia') || tags.containsKey('wikidata')) {
      score += 1;
    }

    // Has image
    if (tags.containsKey('image') || tags.containsKey('wikimedia_commons')) {
      score += 1;
    }

    return score.clamp(1, 7).toString();
  }
}
