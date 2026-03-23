import 'package:flutter/material.dart';

import 'features/books/presentation/books_list_screen.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  runApp(const CommunityBookExchangeApp());
}

class CommunityBookExchangeApp extends StatefulWidget {
  const CommunityBookExchangeApp({super.key});

  static _CommunityBookExchangeAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_CommunityBookExchangeAppState>();
  }

  @override
  State<CommunityBookExchangeApp> createState() =>
      _CommunityBookExchangeAppState();
}

class _CommunityBookExchangeAppState extends State<CommunityBookExchangeApp> {
  Locale? _locale;

  void setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
  }

  Locale? get currentLocale => _locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Book Exchange',
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const BooksListScreen(),
    );
  }
}
