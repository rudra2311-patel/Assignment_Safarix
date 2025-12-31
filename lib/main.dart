import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/auth/login_screen.dart';
import 'core/constants/app_constants.dart';
import 'core/config/env.dart';

/// Main entry point of the Yatraa app
/// Initializes environment variables and starts the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Validate API keys on startup
  _validateApiKeys();

  runApp(const SafarixApp());
}

/// Validate that API keys are loaded correctly
void _validateApiKeys() {
  print('\n🔑 ========== API KEYS VALIDATION ==========');
  print(
    'OpenTripMap API Key: ${Environment.openTripMapApiKey.isEmpty ? "❌ MISSING" : "✅ ${Environment.openTripMapApiKey.substring(0, 20)}..."}',
  );
  print(
    'OpenWeatherMap API Key: ${Environment.openWeatherMapApiKey.isEmpty ? "❌ MISSING" : "✅ ${Environment.openWeatherMapApiKey.substring(0, 20)}..."}',
  );
  print('Has Required Keys: ${Environment.hasRequiredKeys ? "✅ YES" : "❌ NO"}');
  print('==========================================\n');

  if (!Environment.hasRequiredKeys) {
    print('⚠️  WARNING: API keys are missing! App may not work correctly.');
  }
}

/// Root widget of the Safarix application
class SafarixApp extends StatelessWidget {
  const SafarixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Primary color scheme with Indian-inspired orange
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),

        // Typography
        useMaterial3: true,
        fontFamily: 'Roboto',

        // App bar theme
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.orange.shade600,
          foregroundColor: Colors.white,
        ),

        // Card theme
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),

        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      // Start with login screen (placeholder)
      home: const LoginScreen(),
    );
  }
}
