import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse({
    required this.isSuccess,
    this.data,
    this.error,
    required this.statusCode,
  });
}

class ApiService {
  static const String _baseUrl = 'http://localhost:3002/api';

  // 您可以在這裡設置API基礎網址
  String get baseUrl => _baseUrl;

  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers {
    final headers = Map<String, String>.from(_defaultHeaders);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<ApiResponse<dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        error: 'Network error: $e',
        statusCode: 0,
      );
    }
  }

  Future<ApiResponse<dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        error: 'Network error: $e',
        statusCode: 0,
      );
    }
  }

  Future<ApiResponse<dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        error: 'Network error: $e',
        statusCode: 0,
      );
    }
  }

  Future<ApiResponse<dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(url, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        error: 'Network error: $e',
        statusCode: 0,
      );
    }
  }

  ApiResponse<dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final isSuccess = statusCode >= 200 && statusCode < 300;

    dynamic data;
    String? error;

    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        data = response.body;
      }
    }

    if (!isSuccess) {
      error = data is Map<String, dynamic>
          ? data['message'] ?? data['error'] ?? 'Unknown error'
          : 'HTTP $statusCode';
    }

    return ApiResponse(
      isSuccess: isSuccess,
      data: data,
      error: error,
      statusCode: statusCode,
    );
  }
}