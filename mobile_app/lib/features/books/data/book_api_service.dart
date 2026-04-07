import 'dart:convert';

import 'package:http/http.dart' as http;

import 'book_models.dart';

class BookApiService {
  static const String _baseUrl = 'http://localhost:8080';

  final String? bearerToken;

  BookApiService({this.bearerToken});

  Future<List<Book>> fetchBooks() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/books'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load books');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BookDetail> fetchBookDetail(int bookId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/books/$bookId'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load book detail');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    return BookDetail.fromJson(data);
  }

  Future<List<UserSummary>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load users');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => UserSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<CommunitySummary>> fetchCommunities() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/communities'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load communities');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => CommunitySummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> loanBook({
    required int bookId,
    required int loanedToUserId,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/books/$bookId/loan'),
      headers: _headers(includeJson: true),
      body: jsonEncode({'loanedToUserId': loanedToUserId, 'note': note}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  Future<void> returnBook({
    required int bookId,
    required int returnedByUserId,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/books/$bookId/return'),
      headers: _headers(includeJson: true),
      body: jsonEncode({'returnedByUserId': returnedByUserId, 'note': note}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  Future<void> giftBook({
    required int bookId,
    required int newOwnerUserId,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/books/$bookId/gift'),
      headers: _headers(includeJson: true),
      body: jsonEncode({'newOwnerUserId': newOwnerUserId, 'note': note}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  Future<void> donateBook({
    required int bookId,
    required int communityId,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/books/$bookId/donate'),
      headers: _headers(includeJson: true),
      body: jsonEncode({'communityId': communityId, 'note': note}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  Future<BookDetail> extendLoan({
    required int bookId,
    required int requesterUserId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/books/$bookId/extend-loan'),
      headers: _headers(includeJson: true),
      body: jsonEncode({'requesterUserId': requesterUserId}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return BookDetail.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(_extractErrorMessage(response));
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
