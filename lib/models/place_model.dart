/// Model for geographic location (coordinates)
class GeoName {
  final String name;
  final String country;
  final double lat;
  final double lon;
  final int population;
  final String timezone;
  final bool isValid;

  GeoName({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    required this.population,
    required this.timezone,
    this.isValid = true,
  });

  factory GeoName.fromJson(Map<String, dynamic> json) {
    // Check if API returned an error
    if (json['status'] == 'NOT_FOUND' || json['error'] != null) {
      return GeoName(
        name: '',
        country: '',
        lat: 0.0,
        lon: 0.0,
        population: 0,
        timezone: '',
        isValid: false,
      );
    }

    return GeoName(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lon: (json['lon'] ?? 0).toDouble(),
      population: json['population'] ?? 0,
      timezone: json['timezone'] ?? '',
      isValid: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'lat': lat,
      'lon': lon,
      'population': population,
      'timezone': timezone,
    };
  }
}

/// Model for a tourist place (brief info from radius search)
class Place {
  final String xid;
  final String name;
  final String kinds;
  final double dist;
  final Point point;

  Place({
    required this.xid,
    required this.name,
    required this.kinds,
    required this.dist,
    required this.point,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      xid: json['xid'] ?? '',
      name: json['name'] ?? 'Unknown Place',
      kinds: json['kinds'] ?? '',
      dist: (json['dist'] ?? 0).toDouble(),
      point: Point.fromJson(json['point'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xid': xid,
      'name': name,
      'kinds': kinds,
      'dist': dist,
      'point': point.toJson(),
    };
  }
}

/// Model for geographic point (latitude, longitude)
class Point {
  final double lon;
  final double lat;

  Point({required this.lon, required this.lat});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      lon: (json['lon'] ?? 0).toDouble(),
      lat: (json['lat'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'lon': lon, 'lat': lat};
  }
}

/// Model for detailed place information
class PlaceDetail {
  final String xid;
  final String name;
  final String address;
  final String rate;
  final String osm;
  final String wikidata;
  final String kinds;
  final String otm;
  final String wikipedia;
  final String image;
  final Preview? preview;
  final WikipediaExtracts? wikipediaExtracts;
  final Point point;

  PlaceDetail({
    required this.xid,
    required this.name,
    required this.address,
    required this.rate,
    required this.osm,
    required this.wikidata,
    required this.kinds,
    required this.otm,
    required this.wikipedia,
    required this.image,
    this.preview,
    this.wikipediaExtracts,
    required this.point,
  });

  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    return PlaceDetail(
      xid: json['xid'] ?? '',
      name: json['name'] ?? 'Unknown Place',
      address: json['address']?['road'] ?? json['address']?['city'] ?? '',
      rate: json['rate']?.toString() ?? '0',
      osm: json['osm'] ?? '',
      wikidata: json['wikidata'] ?? '',
      kinds: json['kinds'] ?? '',
      otm: json['otm'] ?? '',
      wikipedia: json['wikipedia'] ?? '',
      image: json['image'] ?? '',
      preview: json['preview'] != null
          ? Preview.fromJson(json['preview'])
          : null,
      wikipediaExtracts: json['wikipedia_extracts'] != null
          ? WikipediaExtracts.fromJson(json['wikipedia_extracts'])
          : null,
      point: Point.fromJson(json['point'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xid': xid,
      'name': name,
      'address': address,
      'rate': rate,
      'osm': osm,
      'wikidata': wikidata,
      'kinds': kinds,
      'otm': otm,
      'wikipedia': wikipedia,
      'image': image,
      'preview': preview?.toJson(),
      'wikipedia_extracts': wikipediaExtracts?.toJson(),
      'point': point.toJson(),
    };
  }
}

/// Model for place preview image
class Preview {
  final String source;
  final int height;
  final int width;

  Preview({required this.source, required this.height, required this.width});

  factory Preview.fromJson(Map<String, dynamic> json) {
    return Preview(
      source: json['source'] ?? '',
      height: json['height'] ?? 0,
      width: json['width'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'source': source, 'height': height, 'width': width};
  }
}

/// Model for Wikipedia extracts
class WikipediaExtracts {
  final String title;
  final String text;
  final String html;

  WikipediaExtracts({
    required this.title,
    required this.text,
    required this.html,
  });

  factory WikipediaExtracts.fromJson(Map<String, dynamic> json) {
    return WikipediaExtracts(
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      html: json['html'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'text': text, 'html': html};
  }
}
