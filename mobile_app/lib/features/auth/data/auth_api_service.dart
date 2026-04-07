import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_models.dart';

class AuthApiService {
  static const String _baseUrl = 'http://localhost:8080';

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_extractErrorMessage(response));
    }

    final data = _decodeResponseMap(response.body);

    final token = _readFirstString(data, [
      'token',
      'accessToken',
      'jwt',
      'jwtToken',
    ]);

    if (token == null || token.trim().isEmpty) {
      throw const AuthApiException(
        'Login succeeded but the response did not contain a token.',
      );
    }

    final userData = _extractUserData(data);

    return AuthSession(
      token: token,
      userId: _readFirstInt(userData, ['userId', 'id']),
      name: _readFirstString(userData, ['name', 'displayName', 'fullName']),
      email: _readFirstString(userData, ['email']),
      role: _readFirstString(userData, ['role', 'userRole']),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_extractErrorMessage(response));
    }
  }

  Future<AuthSession> fetchMe(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_extractErrorMessage(response));
    }

    final data = _decodeResponseMap(response.body);

    return AuthSession(
      token: token,
      userId: _readFirstInt(data, ['userId', 'id']),
      name: _readFirstString(data, ['name', 'displayName', 'fullName']),
      email: _readFirstString(data, ['email']),
      role: _readFirstString(data, ['role', 'userRole']),
    );
  }

  Map<String, dynamic> _decodeResponseMap(String body) {
    final decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const AuthApiException('Unexpected response format from server.');
  }

  Map<String, dynamic> _extractUserData(Map<String, dynamic> root) {
    final dynamic user = root['user'];

    if (user is Map<String, dynamic>) {
      return user;
    }

    return root;
  }

  String? _readFirstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) {
        continue;
      }

      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  int? _readFirstInt(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];

      if (value is int) {
        return value;
      }

      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    return null;
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {
      // Ignore parsing errors and use fallback below.
    }

    return 'Request failed with status ${response.statusCode}';
  }
}
