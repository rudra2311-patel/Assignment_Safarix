import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';

/// Base class for all API services
/// Provides common HTTP methods and error handling
abstract class BaseApiService {
  final String baseUrl;
  final Duration timeout;

  BaseApiService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 15),
  });

  /// GET request with automatic error handling
  Future<Map<String, dynamic>?> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      Logger.api('GET', uri.toString());

      final response = await http.get(uri).timeout(timeout);
      Logger.api('GET', uri.toString(), response.statusCode);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        Logger.warn('HTTP ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e, stack) {
      Logger.error('GET request failed', e, stack);
      return null;
    }
  }

  /// POST request with body
  Future<Map<String, dynamic>?> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final defaultHeaders = {'Content-Type': 'application/json'};
      final mergedHeaders = {...defaultHeaders, ...?headers};

      Logger.api('POST', uri.toString());

      final response = await http
          .post(
            uri,
            headers: mergedHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      Logger.api('POST', uri.toString(), response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        Logger.warn('HTTP ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e, stack) {
      Logger.error('POST request failed', e, stack);
      return null;
    }
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final url = '$baseUrl$endpoint';
    if (queryParams != null && queryParams.isNotEmpty) {
      return Uri.parse(url).replace(queryParameters: queryParams);
    }
    return Uri.parse(url);
  }
}
