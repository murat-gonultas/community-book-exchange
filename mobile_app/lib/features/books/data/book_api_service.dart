import 'dart:convert';

import 'package:http/http.dart' as http;

import 'book_models.dart';

class BookApiService {
  static const String _baseUrl = 'http://localhost:8080';

  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/books'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load books');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BookDetail> fetchBookDetail(int bookId) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/books/$bookId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load book detail');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    return BookDetail.fromJson(data);
  }

  Future<List<UserSummary>> fetchUsers() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/users'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load users');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => UserSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<CommunitySummary>> fetchCommunities() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/communities'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load communities');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => CommunitySummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> reserveBook({
    required int bookId,
    required int reservedForUserId,
    required int reservedDays,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/books/$bookId/reserve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reservedForUserId': reservedForUserId,
        'reservedDays': reservedDays,
        'note': note,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  Future<void> loanBook({
    required int bookId,
    required int loanedToUserId,
    required int loanDays,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/books/$bookId/loan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'loanedToUserId': loanedToUserId,
        'loanDays': loanDays,
        'note': note,
      }),
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
      headers: {'Content-Type': 'application/json'},
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
      headers: {'Content-Type': 'application/json'},
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
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'communityId': communityId, 'note': note}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }
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
