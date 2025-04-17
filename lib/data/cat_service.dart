import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/cat.dart';

class CatService {
  static const String _baseUrl = 'https://api.thecatapi.com/v1';
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;
  final String _apiKey = dotenv.env['CAT_API_KEY'] ?? '';

  CatService({http.Client? client}) : _client = client ?? http.Client();

  Future<Cat?> fetchRandomCat() async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final response = await _client
            .get(
              Uri.parse('$_baseUrl/images/search?has_breeds=1'),
              headers: _apiKey.isEmpty ? {} : {'x-api-key': _apiKey},
            )
            .timeout(_timeout);
        return _handleResponse(response);
      } catch (_) {
        if (attempt == _maxRetries - 1) rethrow;
      }
      await Future.delayed(Duration(seconds: 1 << attempt));
    }
    return null;
  }

  Cat? _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return _parseJson(response.body);
    }
    throw Exception('Failed to load cat');
  }

  Cat? _parseJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as List;
      if (data.isEmpty) return null;
      return Cat.fromJson(data.first);
    } catch (_) {
      return null;
    }
  }
}
