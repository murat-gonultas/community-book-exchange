import 'dart:convert';

import 'package:http/http.dart' as http;

import 'borrow_request_models.dart';

class BorrowRequestApiService {
  static const String _baseUrl = 'http://localhost:8080';

  final String? bearerToken;

  BorrowRequestApiService({this.bearerToken});

  Future<List<BorrowRequestItem>> fetchMyRequests() async {
    _ensureAuthenticated();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/borrow-requests/me'),
      headers: _headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => BorrowRequestItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<BorrowRequestItem>> fetchIncomingRequests() async {
    _ensureAuthenticated();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/borrow-requests/incoming'),
      headers: _headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => BorrowRequestItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createBorrowRequest({
    required int bookId,
    String? message,
  }) async {
    _ensureAuthenticated();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/books/$bookId/borrow-requests'),
      headers: _headers(includeJson: true),
      body: jsonEncode({'message': (message ?? '').trim()}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  Future<void> approveBorrowRequest({
    required int borrowRequestId,
    String? decisionNote,
  }) async {
    _ensureAuthenticated();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/borrow-requests/$borrowRequestId/approve'),
      headers: _headers(includeJson: true),
      body: jsonEncode({'decisionNote': (decisionNote ?? '').trim()}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  Future<void> rejectBorrowRequest({
    required int borrowRequestId,
    required String rejectionReason,
    String? decisionNote,
  }) async {
    _ensureAuthenticated();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/borrow-requests/$borrowRequestId/reject'),
      headers: _headers(includeJson: true),
      body: jsonEncode({
        'rejectionReason': rejectionReason.trim(),
        'decisionNote': (decisionNote ?? '').trim(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  Future<void> cancelBorrowRequest({required int borrowRequestId}) async {
    _ensureAuthenticated();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/borrow-requests/$borrowRequestId/cancel'),
      headers: _headers(includeJson: true),
      body: jsonEncode({}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  Future<void> fulfillBorrowRequest({
    required int borrowRequestId,
    String? note,
  }) async {
    _ensureAuthenticated();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/borrow-requests/$borrowRequestId/fulfill'),
      headers: _headers(includeJson: true),
      body: jsonEncode({'note': (note ?? '').trim()}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  void _ensureAuthenticated() {
    if (bearerToken == null || bearerToken!.trim().isEmpty) {
      throw Exception('No authenticated session available.');
    }
  }

  Map<String, String> _headers({bool includeJson = false}) {
    final headers = <String, String>{};

    if (includeJson) {
      headers['Content-Type'] = 'application/json';
    }

    if (bearerToken != null && bearerToken!.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    return headers;
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final dynamic body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        final message = body['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Ignore JSON parsing errors and fall back to generic message.
    }

    return 'Request failed with status ${response.statusCode}';
  }
}
