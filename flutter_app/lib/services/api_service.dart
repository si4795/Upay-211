import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _defaultLocalhost = 'http://127.0.0.1:8000';
  static const String _defaultAndroidEmulator = 'http://10.0.2.2:8000';

  final String baseUrl;

  ApiService({String? baseUrl})
      : baseUrl = baseUrl ??
            (!kIsWeb && defaultTargetPlatform == TargetPlatform.android
                ? _defaultAndroidEmulator
                : _defaultLocalhost);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('GET $endpoint failed: $e');
      rethrow;
    }
  }

  String get wsUrl {
    if (baseUrl.startsWith('https://')) {
      return baseUrl.replaceFirst('https://', 'wss://');
    }
    return baseUrl.replaceFirst('http://', 'ws://');
  }

  Future<dynamic> getJson(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('GET $endpoint failed: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getList(String endpoint) async {
    final res = await getJson(endpoint);
    if (res is List) return res;
    return [];
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .post(uri, headers: _headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('POST $endpoint failed: $e');
      rethrow;
    }
  }
}

