import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/weather_model.dart';
import '../../services/weather_service.dart';

/// Concise Weather Details Screen with Reusable Components
/// Real forecast data from OpenWeatherMap API (not dummy data!)
class WeatherDetailsScreen extends StatefulWidget {
  final Weather currentWeather;
  final double latitude;
  final double longitude;

  const WeatherDetailsScreen({
    super.key,
    required this.currentWeather,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<WeatherDetailsScreen> createState() => _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends State<WeatherDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final WeatherService _weatherService = WeatherService();
  List<Weather> _forecast = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    final forecast = await _weatherService.getForecastByCoordinates(
      lat: widget.latitude,
      lon: widget.longitude,
    );
    if (mounted) setState(() => (_forecast = forecast, _isLoading = false));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _gradientStart() {
    final icon = widget.currentWeather.icon;
    if (icon.contains('01')) return const Color(0xFF1e3c72);
    if (icon.contains('02')) return const Color(0xFF2193b0);
    if (icon.contains('03') || icon.contains('04'))
      return const Color(0xFF373B44);
    if (icon.contains('09') || icon.contains('10'))
      return const Color(0xFF2C3E50);
    if (icon.contains('11')) return const Color(0xFF141E30);
    if (icon.contains('13')) return const Color(0xFF83a4d4);
    if (icon.contains('50')) return const Color(0xFF757F9A);
    return const Color(0xFF1e3c72);
  }

  Color _gradientEnd() {
    final icon = widget.currentWeather.icon;
    if (icon.contains('01')) return const Color(0xFF2a5298);
    if (icon.contains('02')) return const Color(0xFF6dd5ed);
    if (icon.contains('03') || icon.contains('04'))
      return const Color(0xFF4A4E69);
    if (icon.contains('09') || icon.contains('10'))
      return const Color(0xFF4CA1AF);
    if (icon.contains('11')) return const Color(0xFF243B55);
    if (icon.contains('13')) return const Color(0xFFb6fbff);
    if (icon.contains('50')) return const Color(0xFFD7DDE8);
    return const Color(0xFF2a5298);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_gradientStart(), _gradientEnd()],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _animController,
            child: Column(
              children: [
                _AppBar(city: widget.currentWeather.cityName),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _CurrentWeather(weather: widget.currentWeather),
                        const SizedBox(height: 30),
                        _WeatherDetails(weather: widget.currentWeather),
                        const SizedBox(height: 30),
                        if (_isLoading)
                          const CircularProgressIndicator(color: Colors.white)
                        else if (_forecast.isNotEmpty) ...[
                          _HourlyForecast(forecast: _forecast.take(8).toList()),
                          const SizedBox(height: 30),
                          _DailyForecast(forecast: _forecast),
                        ],
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable Components

class _AppBar extends StatelessWidget {
  final String city;
  const _AppBar({required this.city});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Weather Forecast',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentWeather extends StatelessWidget {
  final Weather weather;
  const _CurrentWeather({required this.weather});

  @override
  Widget build(BuildContext context) {
    return _AnimatedWidget(
      child: Column(
        children: [
          _RotatingIcon(iconUrl: weather.iconUrl),
          const SizedBox(height: 20),
          _PulsingWidget(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Colors.white70],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: Text(
                '${weather.temperature.toStringAsFixed(0)}\u00b0',
                style: const TextStyle(
                  fontSize: 90,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _GlassCard(
            child: Text(
              weather.description.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.thermostat,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Feels like ${weather.feelsLike.toStringAsFixed(0)}\u00b0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherDetails extends StatelessWidget {
  final Weather weather;
  const _WeatherDetails({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _GlassCard(
        padding: 20,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailItem(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: '${weather.humidity}%',
                  delay: 0,
                ),
                _DetailItem(
                  icon: Icons.air,
                  label: 'Wind',
                  value: weather.windSpeedFormatted,
                  delay: 100,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailItem(
                  icon: Icons.speed,
                  label: 'Pressure',
                  value: '${weather.pressure ?? 0} hPa',
                  delay: 200,
                ),
                _DetailItem(
                  icon: Icons.visibility,
                  label: 'Visibility',
                  value:
                      '${((weather.visibility ?? 0) / 1000).toStringAsFixed(1)} km',
                  delay: 300,
                ),
              ],
            ),
            if (weather.clouds != null) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DetailItem(
                    icon: Icons.cloud,
                    label: 'Cloudiness',
                    value: '${weather.clouds}%',
                    delay: 400,
                  ),
                  _DetailItem(
                    icon: Icons.thermostat,
                    label: 'Feels Like',
                    value: '${weather.feelsLike.toStringAsFixed(1)}\u00b0C',
                    delay: 500,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int delay;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final clamped = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: clamped,
          child: Opacity(opacity: clamped, child: child),
        );
      },
      child: Column(
        children: [
          _GradientCircle(child: Icon(icon, color: Colors.white, size: 28)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyForecast extends StatelessWidget {
  final List<Weather> forecast;
  const _HourlyForecast({required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: Icons.access_time, title: 'HOURLY FORECAST'),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            physics: const BouncingScrollPhysics(),
            itemCount: forecast.length,
            itemBuilder: (context, index) => _AnimatedCard(
              index: index,
              child: _HourlyCard(weather: forecast[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _HourlyCard extends StatelessWidget {
  final Weather weather;
  const _HourlyCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return _PulsingWidget(
      child: Container(
        width: 95,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: _glassDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weather.formattedTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            _BouncingIcon(iconUrl: weather.iconUrl, size: 38),
            const SizedBox(height: 6),
            _GlassCard(
              child: Text(
                '${weather.temperature.toStringAsFixed(0)}\u00b0',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyForecast extends StatelessWidget {
  final List<Weather> forecast;
  const _DailyForecast({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Weather>>{};
    for (final w in forecast) {
      grouped.putIfAbsent(w.formattedDate, () => []).add(w);
    }
    final dailyData = grouped.entries.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: Icons.calendar_today, title: '5-DAY FORECAST'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: dailyData.asMap().entries.map((entry) {
              final temps = entry.value.value
                  .map((w) => w.temperature)
                  .toList();
              final weather = entry.value.value[entry.value.value.length ~/ 2];
              return _AnimatedSlide(
                index: entry.key,
                child: _DailyCard(
                  day: weather.dayOfWeek,
                  date: entry.value.key,
                  iconUrl: weather.iconUrl,
                  minTemp: temps.reduce(math.min),
                  maxTemp: temps.reduce(math.max),
                  description: weather.description,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DailyCard extends StatelessWidget {
  final String day, date, iconUrl, description;
  final double minTemp, maxTemp;

  const _DailyCard({
    required this.day,
    required this.date,
    required this.iconUrl,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: _glassDecoration(),
      child: Row(
        children: [
          SizedBox(
            width: 75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _GradientCircle(
            child: Image.network(
              iconUrl,
              width: 42,
              height: 42,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.wb_sunny, color: Colors.white, size: 42),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              _GlassCard(
                child: Text(
                  '${maxTemp.toStringAsFixed(0)}\u00b0',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${minTemp.toStringAsFixed(0)}\u00b0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Reusable Widgets

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _GradientCircle(
            padding: 8,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double? padding;
  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding != null
          ? EdgeInsets.all(padding!)
          : const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: child,
    );
  }
}

class _GradientCircle extends StatelessWidget {
  final Widget child;
  final double? padding;
  const _GradientCircle({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding ?? 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.15),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

BoxDecoration _glassDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white.withOpacity(0.22), Colors.white.withOpacity(0.12)],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

// Animation Widgets

class _AnimatedWidget extends StatelessWidget {
  final Widget child;
  const _AnimatedWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) {
        final clamped = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: 0.8 + (0.2 * clamped),
          child: Opacity(opacity: clamped, child: child),
        );
      },
      child: child,
    );
  }
}

class _AnimatedCard extends StatelessWidget {
  final int index;
  final Widget child;
  const _AnimatedCard({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (_, value, child) {
        final clamped = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: clamped,
          child: Opacity(opacity: clamped, child: child),
        );
      },
      child: child,
    );
  }
}

class _AnimatedSlide extends StatelessWidget {
  final int index;
  final Widget child;
  const _AnimatedSlide({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (_, value, child) {
        final clamped = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(50 * (1 - clamped), 0),
          child: Opacity(opacity: clamped, child: child),
        );
      },
      child: child,
    );
  }
}

class _RotatingIcon extends StatelessWidget {
  final String iconUrl;
  const _RotatingIcon({required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 3),
      builder: (_, value, child) {
        final rotation = value.clamp(0.0, 1.0);
        return Transform.rotate(
          angle: math.sin(rotation * math.pi * 2) * 0.15,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3 * rotation),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Image.network(
              iconUrl,
              width: 140,
              height: 140,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.wb_sunny, size: 140, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

class _BouncingIcon extends StatelessWidget {
  final String iconUrl;
  final double size;
  const _BouncingIcon({required this.iconUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2000),
      builder: (_, value, child) => Transform.scale(
        scale: 0.9 + (0.1 * math.sin(value * math.pi * 2)),
        child: child,
      ),
      child: Image.network(
        iconUrl,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.wb_sunny, color: Colors.white, size: size),
      ),
    );
  }
}

class _PulsingWidget extends StatelessWidget {
  final Widget child;
  const _PulsingWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (_, scale, child) =>
          Transform.scale(scale: scale.clamp(0.95, 1.0), child: child),
      child: child,
    );
  }
}
