import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/data/auth_models.dart';
import 'features/auth/data/session_storage.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/books/presentation/books_list_screen.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  final SessionStorage _sessionStorage = SessionStorage();

  Locale? _locale;
  AuthSession? _session;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_localeKey);
    final savedSession = await _sessionStorage.load();

    if (!mounted) {
      return;
    }

    setState(() {
      if (savedCode == null || savedCode == 'system') {
        _locale = null;
      } else {
        _locale = Locale(savedCode);
      }

      _session = savedSession;
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

    if (!mounted) {
      return;
    }

    setState(() {
      _locale = locale;
    });
  }

  Future<void> setSession(AuthSession session) async {
    await _sessionStorage.save(session);

    if (!mounted) {
      return;
    }

    setState(() {
      _session = session;
    });
  }

  Future<void> logout() async {
    await _sessionStorage.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      _session = null;
    });
  }

  Locale? get currentLocale => _locale;
  AuthSession? get currentSession => _session;
  bool get isAuthenticated => _session != null;
  int? get currentUserId => _session?.userId;

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
      home: _session == null
          ? AuthScreen(onLoginSuccess: setSession)
          : const BooksListScreen(),
    );
  }
}
