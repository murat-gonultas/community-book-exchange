import 'package:flutter/material.dart';

import 'features/books/presentation/books_list_screen.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  runApp(const CommunityBookExchangeApp());
}

class CommunityBookExchangeApp extends StatelessWidget {
  const CommunityBookExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Book Exchange',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const BooksListScreen(),
    );
  }
}
