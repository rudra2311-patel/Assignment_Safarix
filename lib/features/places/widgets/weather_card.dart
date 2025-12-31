import 'package:flutter/material.dart';
import '../../../models/weather_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../weather/weather_details_screen.dart';

/// Reusable weather card widget
/// Displays weather information
class WeatherCard extends StatelessWidget {
  final Weather weather;
  final double latitude;
  final double longitude;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherDetailsScreen(
              currentWeather: weather,
              latitude: latitude,
              longitude: longitude,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(AppConstants.defaultPadding),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
          ),
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildWeatherIcon(),
            const SizedBox(width: 16),
            Expanded(child: _buildWeatherInfo()),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherIcon() {
    return Image.network(
      weather.iconUrl,
      width: 64,
      height: 64,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.wb_sunny, size: 64, color: Colors.white),
    );
  }

  Widget _buildWeatherInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          weather.tempCelsius,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          weather.description.toUpperCase(),
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.water_drop,
              size: 16,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(width: 4),
            Text(
              '${weather.humidity}%',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(width: 16),
            Icon(Icons.air, size: 16, color: Colors.white.withOpacity(0.8)),
            const SizedBox(width: 4),
            Text(
              weather.windSpeedFormatted,
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ],
    );
  }
}
