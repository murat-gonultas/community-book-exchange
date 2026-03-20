import 'package:flutter/material.dart';

import '../data/book_api_service.dart';
import '../data/book_models.dart';
import 'book_detail_screen.dart';

class BooksListScreen extends StatefulWidget {
  const BooksListScreen({super.key});

  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  final BookApiService _apiService = BookApiService();
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _apiService.fetchBooks();
  }

  Future<void> _reloadBooks() async {
    setState(() {
      _booksFuture = _apiService.fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Books')),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load books.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _reloadBooks,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reloadBooks,
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No books found')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reloadBooks,
            child: ListView.separated(
              itemCount: books.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final book = books[index];

                return ListTile(
                  leading: CircleAvatar(child: Text(book.bookId.toString())),
                  title: Text(book.title),
                  subtitle: Text(
                    '${book.author ?? 'Unknown'} • ${book.status} • ${book.ownershipType}',
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookDetailScreen(bookId: book.bookId),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
