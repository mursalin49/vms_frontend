import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_constants.dart';
import 'app_exceptions.dart';
import 'auth_token_storage.dart';

/// Centralized HTTP client for making API requests.
///
/// Features:
/// - Automatically prepends [ApiConstants.baseUrl]
/// - Attaches JSON headers (`Content-Type` and `Accept`)
/// - Automatically injects `Authorization: Bearer <token>` when available
/// - Maps HTTP status codes to strongly typed [AppException] subclasses
class ApiClient {
  final http.Client _httpClient;
  final Duration timeout;

  ApiClient({http.Client? httpClient, this.timeout = const Duration(seconds: 60)})
      : _httpClient = httpClient ?? http.Client();

  /// Builds standard headers with JSON Content-Type and optional Bearer token
  Map<String, String> _buildHeaders(Map<String, String>? extraHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = AuthTokenStorage().token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Uri _resolveUri(String endpoint) {
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return Uri.parse(endpoint);
    }
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('$base$path');
  }

  /// GET request
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    return _send(() async {
      final uri = _resolveUri(endpoint);
      final response = await _httpClient
          .get(uri, headers: _buildHeaders(headers))
          .timeout(timeout);
      return _handleResponse(response);
    });
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _send(() async {
      final uri = _resolveUri(endpoint);
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _httpClient
          .post(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(timeout);
      return _handleResponse(response);
    });
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _send(() async {
      final uri = _resolveUri(endpoint);
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _httpClient
          .put(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(timeout);
      return _handleResponse(response);
    });
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    return _send(() async {
      final uri = _resolveUri(endpoint);
      final response = await _httpClient
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(timeout);
      return _handleResponse(response);
    });
  }

  /// Error boundary for network and system errors
  Future<T> _send<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AppException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException(
        'Server took too long to respond. Render free tier may be waking up, please retry.',
      );
    } on http.ClientException catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('xmlhttprequest') || msg.contains('clientexception')) {
        throw const NetworkException(
          'Browser CORS policy blocked the request. Run with: flutter run -d chrome --web-browser-flag="--disable-web-security"',
        );
      }
      throw const NetworkException();
    } catch (e) {
      if (e is FormatException) {
        throw AppException('Invalid response format received from server: ${e.message}');
      }
      throw AppException(e.toString());
    }
  }

  /// Evaluates HTTP response status code and parses body
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final bodyString = response.body.trim();

    // 204 No Content
    if (statusCode == 204 || bodyString.isEmpty) {
      return null;
    }

    dynamic parsedBody;
    if (bodyString.startsWith('{') || bodyString.startsWith('[')) {
      try {
        parsedBody = jsonDecode(bodyString);
      } catch (_) {
        parsedBody = bodyString;
      }
    } else {
      parsedBody = bodyString;
    }

    // Success: 200..299
    if (statusCode >= 200 && statusCode < 300) {
      return parsedBody;
    }

    // Extract error message if present in JSON
    String? errorMessage;
    if (parsedBody is Map) {
      errorMessage = parsedBody['message']?.toString() ??
          parsedBody['error']?.toString() ??
          parsedBody['detail']?.toString();
    } else if (parsedBody is String && parsedBody.isNotEmpty) {
      errorMessage = parsedBody;
    }

    // Error mapping based on HTTP status
    switch (statusCode) {
      case 400:
        throw AppException(errorMessage ?? 'Invalid request parameters.');
      case 401:
        throw InvalidCredentialsException(
          errorMessage ?? 'Invalid email or password.',
        );
      case 403:
        throw UnauthorizedException(
          errorMessage ?? 'Access denied. You do not have permission.',
        );
      case 404:
        throw NotFoundException(errorMessage ?? 'Requested resource not found.');
      case 409:
        throw const DuplicateVehicleException();
      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerException(
          errorMessage ?? 'Server is currently unavailable. Please try again.',
        );
      default:
        throw AppException(
          errorMessage ?? 'Request failed with status: $statusCode',
        );
    }
  }
}

