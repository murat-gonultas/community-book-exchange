import 'dart:convert';

import 'package:http/http.dart' as http;

import 'book_models.dart';

class BookApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books'));
    _checkResponse(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BookDetail> fetchBookDetail(int bookId) async {
    final response = await http.get(Uri.parse('$baseUrl/books/$bookId'));
    _checkResponse(response);

    final Map<String, dynamic> data = jsonDecode(response.body);
    return BookDetail.fromJson(data);
  }

  Future<void> reserveBook({
    required int bookId,
    required int reservedForUserId,
    required int reservedDays,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books/$bookId/reserve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reservedForUserId': reservedForUserId,
        'reservedDays': reservedDays,
        'note': note,
      }),
    );

    _checkResponse(response);
  }

  Future<void> loanBook({
    required int bookId,
    required int loanedToUserId,
    required int loanDays,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books/$bookId/loan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'loanedToUserId': loanedToUserId,
        'loanDays': loanDays,
        'note': note,
      }),
    );

    _checkResponse(response);
  }

  Future<void> returnBook({
    required int bookId,
    required int returnedByUserId,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books/$bookId/return'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'returnedByUserId': returnedByUserId, 'note': note}),
    );

    _checkResponse(response);
  }

  Future<void> giftBook({
    required int bookId,
    required int newOwnerUserId,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books/$bookId/gift'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newOwnerUserId': newOwnerUserId, 'note': note}),
    );

    _checkResponse(response);
  }

  Future<void> donateBook({
    required int bookId,
    required int communityId,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books/$bookId/donate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'communityId': communityId, 'note': note}),
    );

    _checkResponse(response);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
