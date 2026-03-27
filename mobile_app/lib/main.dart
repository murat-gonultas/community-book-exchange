import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/books/presentation/books_list_screen.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  runApp(const CommunityBookExchangeApp());
}

class CommunityBookExchangeApp extends StatefulWidget {
  const CommunityBookExchangeApp({super.key});

  static CommunityBookExchangeAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<CommunityBookExchangeAppState>();
  }

  @override
  State<CommunityBookExchangeApp> createState() =>
      CommunityBookExchangeAppState();
}

class CommunityBookExchangeAppState extends State<CommunityBookExchangeApp> {
  static const String _localeKey = 'selected_locale_code';

  Locale? _locale;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_localeKey);

    if (!mounted) return;

    setState(() {
      if (savedCode == null || savedCode == 'system') {
        _locale = null;
      } else {
        _locale = Locale(savedCode);
      }
      _isInitialized = true;
    });
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();

    if (locale == null) {
      await prefs.setString(_localeKey, 'system');
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }

    if (!mounted) return;

    setState(() {
      _locale = locale;
    });
  }

  Locale? get currentLocale => _locale;

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Community Book Exchange',
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const BooksListScreen(),
    );
  }
}
