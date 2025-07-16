import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

abstract class ApiServiceInterface {
  Future<dynamic> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      });
  Future<dynamic> post(String endpoint, Map<String, dynamic> data);
  Future<dynamic> put(String endpoint, Map<String, dynamic> data);
  Future<dynamic> delete(String endpoint);
  Future<dynamic> uploadFile(String endpoint, File file, {Map<String, String>? fields});
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJson(json['data']) : null,
      message: json['message'],
      statusCode: json['statusCode'] ?? 200,
    );
  }

  factory ApiResponse.error(String message, {int statusCode = 500}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

class ApiService implements ApiServiceInterface {
  final http.Client _client;
  final String baseUrl;

  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      debugPrint('İstek için token kullanılıyor: ${token.length > 10 ? token.substring(0, 10) + '...' : token}');
    } else {
      debugPrint('Token bulunamadı, kimlik doğrulamasız istek yapılıyor');
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    debugPrint('Response Status Code: ${response.statusCode}');

    if (response.body.length > 1000) {
      debugPrint('Response Body (truncated): ${response.body.substring(0, 1000)}...');
    } else {
      debugPrint('Response Body: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }

      try {
        String utf8Body = utf8.decode(response.bodyBytes);

        final jsonBody = jsonDecode(utf8Body);

        debugPrint('Parsed JSON structure: ${jsonBody.runtimeType}');

        return jsonBody;
      } catch (e) {
        debugPrint('JSON Parse Error: ${e.toString()}');
        debugPrint('Response Body for failed parse: ${response.body}');
        return {
          'parse_error': true,
          'error_message': e.toString(),
          'original_response': response.body
        };
      }
    } else {
      debugPrint('Error Response Status: ${response.statusCode}');
      debugPrint('Error Response Body: ${response.body}');

      try {
        final errorJson = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage = errorJson['message'] ?? 'Unknown error occurred';
        throw Exception('Server error: $errorMessage');
      } catch (parseError) {
        switch (response.statusCode) {
          case 400:
            throw Exception('Bad request: Please check your input');
          case 401:
            throw Exception('Unauthorized: Please login again');
          case 403:
            throw Exception('Forbidden: You don\'t have permission');
          case 404:
            throw Exception('Not found: The requested resource was not found');
          case 500:
            throw Exception('Server error: Please try again later');
          default:
            throw Exception('Request failed with status: ${response.statusCode}');
        }
      }
    }
  }

  @override
  Future<dynamic> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParameters?.map(
              (key, value) => MapEntry(key, value.toString())
      ),
    );

    try {
      debugPrint('GET Request URL: $uri');
      debugPrint('GET Request Headers: $headers');

      final response = await _client.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Network error in GET: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      debugPrint('POST Request URL: $uri');
      debugPrint('POST Request Headers: $headers');
      debugPrint('POST Request Data: $data');

      final jsonData = jsonEncode(data);
      debugPrint('POST Request JSON Data: $jsonData');

      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonData,
      );

      debugPrint('POST Response Status: ${response.statusCode}');
      if (response.body.length > 500) {
        debugPrint('POST Response Body (truncated): ${response.body.substring(0, 500)}...');
      } else {
        debugPrint('POST Response Body: ${response.body}');
      }

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Network error in POST: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      debugPrint('PUT Request URL: $uri');
      debugPrint('PUT Request Headers: $headers');
      debugPrint('PUT Request Data: $data');

      final jsonData = jsonEncode(data);
      debugPrint('PUT Request JSON Data: $jsonData');

      final response = await _client.put(
        uri,
        headers: headers,
        body: jsonData,
      );

      debugPrint('PUT Response Status: ${response.statusCode}');
      if (response.body.length > 500) {
        debugPrint('PUT Response Body (truncated): ${response.body.substring(0, 500)}...');
      } else {
        debugPrint('PUT Response Body: ${response.body}');
      }

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Network error in PUT: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      debugPrint('DELETE Request URL: $uri');
      debugPrint('DELETE Request Headers: $headers');

      final response = await _client.delete(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Network error in DELETE: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<dynamic> uploadFile(String endpoint, File file, {Map<String, String>? fields}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    headers['Content-Type'] = 'multipart/form-data';

    try {
      debugPrint('Upload Request URL: $uri');
      debugPrint('File path: ${file.path}');
      debugPrint('Upload Headers: $headers');

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.files.add(
        await http.MultipartFile.fromPath('image', file.path),
      );

      if (fields != null) {
        debugPrint('Additional Fields: $fields');
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Upload Response Status Code: ${response.statusCode}');
      debugPrint('Upload Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('File upload error: $e');
      throw Exception('Network error during file upload: $e');
    }
  }
}

final apiServiceProvider = Provider<ApiServiceInterface>((ref) {
  return ApiService();
});