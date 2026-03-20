import 'package:flutter/material.dart';
import 'features/books/presentation/books_list_screen.dart';

void main() {
  runApp(const CommunityBookExchangeApp());
}

class CommunityBookExchangeApp extends StatelessWidget {
  const CommunityBookExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Book Exchange',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BooksListScreen(),
    );
  }
}
