/// Model for weather information
class Weather {
  final String cityName;
  final String description;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String icon;
  final int timestamp;
  final int? pressure;
  final int? visibility;
  final int? clouds;
  final double? tempMin;
  final double? tempMax;

  Weather({
    required this.cityName,
    required this.description,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.timestamp,
    this.pressure,
    this.visibility,
    this.clouds,
    this.tempMin,
    this.tempMax,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final main = json['main'] ?? {};
    final weather = (json['weather'] as List?)?.first ?? {};
    final wind = json['wind'] ?? {};
    final clouds = json['clouds'] ?? {};

    return Weather(
      cityName: json['name'] ?? '',
      description: weather['description'] ?? '',
      temperature: (main['temp'] ?? 0).toDouble(),
      feelsLike: (main['feels_like'] ?? 0).toDouble(),
      humidity: main['humidity'] ?? 0,
      windSpeed: (wind['speed'] ?? 0).toDouble(),
      icon: weather['icon'] ?? '01d',
      timestamp: json['dt'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      pressure: main['pressure'],
      visibility: json['visibility'],
      clouds: clouds['all'],
      tempMin: (main['temp_min'] ?? 0).toDouble(),
      tempMax: (main['temp_max'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'weather': [
        {'description': description, 'icon': icon},
      ],
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
      },
      'wind': {'speed': windSpeed},
      'dt': timestamp,
    };
  }

  /// Get weather icon URL from OpenWeatherMap
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  /// Get DateTime from timestamp
  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  /// Get formatted date
  String get formattedDate {
    final date = dateTime;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Get formatted time
  String get formattedTime {
    final date = dateTime;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get day of week
  String get dayOfWeek {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dateTime.weekday - 1];
  }

  /// Get formatted temperature in Celsius
  String get tempCelsius => '${temperature.toStringAsFixed(1)}°C';

  /// Get formatted wind speed
  String get windSpeedFormatted => '${windSpeed.toStringAsFixed(1)} m/s';
}
