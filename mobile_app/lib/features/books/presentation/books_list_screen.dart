import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/generated/app_localizations.dart';

import '../../../main.dart';
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

  void _changeLanguage(String value) {
    final appState = CommunityBookExchangeApp.of(context);

    if (appState == null) return;

    switch (value) {
      case 'system':
        appState.setLocale(null);
        break;
      case 'de':
        appState.setLocale(const Locale('de'));
        break;
      case 'en':
        appState.setLocale(const Locale('en'));
        break;
      case 'tr':
        appState.setLocale(const Locale('tr'));
        break;
    }
  }

  Future<void> _reloadBooks() async {
    setState(() {
      _booksFuture = _apiService.fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.books),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.language,
            onSelected: _changeLanguage,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'system', child: Text(l10n.systemLanguage)),
              PopupMenuItem(value: 'de', child: Text(l10n.german)),
              PopupMenuItem(value: 'en', child: Text(l10n.english)),
              PopupMenuItem(value: 'tr', child: Text(l10n.turkish)),
            ],
            icon: const Icon(Icons.language),
          ),
        ],
      ),
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
                      l10n.failedToLoadBooks(snapshot.error.toString()),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _reloadBooks,
                      child: Text(l10n.retry),
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
                children: [
                  const SizedBox(height: 200),
                  Center(child: Text(l10n.noBooksFound)),
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
                    '${book.author ?? l10n.unknownAuthor} • ${book.status} • ${book.ownershipType}',
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
