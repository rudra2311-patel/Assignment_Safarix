import 'package:flutter_test/flutter_test.dart';
import 'package:safarix/core/config/env.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    // Load environment variables
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
  });

  group('Environment Configuration Tests', () {
    test('API keys should be loaded from environment', () {
      expect(Environment.openTripMapApiKey, isNotEmpty);
      expect(Environment.openWeatherMapApiKey, isNotEmpty);
    });

    test('Required keys should be present', () {
      expect(Environment.hasRequiredKeys, isTrue);
    });
  });
}
