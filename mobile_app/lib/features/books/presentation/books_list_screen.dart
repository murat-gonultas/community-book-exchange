import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/generated/app_localizations.dart';

import '../../../main.dart';
import '../../auth/data/auth_models.dart';
import '../../borrow_requests/presentation/incoming_borrow_requests_screen.dart';
import '../../borrow_requests/presentation/my_borrow_requests_screen.dart';
import '../data/book_api_service.dart';
import '../data/book_models.dart';
import 'book_detail_screen.dart';
import 'book_ui_labels.dart';

class BooksListScreen extends StatefulWidget {
  const BooksListScreen({super.key});

  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  final TextEditingController _searchController = TextEditingController();

  late BookApiService _apiService;
  Future<List<Book>>? _booksFuture;

  String? _selectedStatus;
  String? _selectedOwnershipType;
  bool _didLoad = false;

  static const List<String> _statusOptions = ['AVAILABLE', 'ON_LOAN'];
  static const List<String> _ownershipOptions = ['USER', 'COMMUNITY'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final token = CommunityBookExchangeApp.of(context)?.currentSession?.token;
    _apiService = BookApiService(bearerToken: token);

    if (!_didLoad) {
      _booksFuture = _apiService.fetchBooks();
      _didLoad = true;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _changeLanguage(String value) {
    final appState = CommunityBookExchangeApp.of(context);

    if (appState == null) {
      return;
    }

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

  Future<void> _logout() async {
    final appState = CommunityBookExchangeApp.of(context);
    await appState?.logout();
  }

  Future<void> _reloadBooks() async {
    setState(() {
      _booksFuture = _apiService.fetchBooks();
    });

    await _booksFuture;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _selectedOwnershipType = null;
    });
  }

  List<Book> _applyFilters(List<Book> books) {
    final query = _searchController.text.trim().toLowerCase();

    return books.where((book) {
      final title = book.title.toLowerCase();
      final author = (book.author ?? '').toLowerCase();

      final matchesSearch =
          query.isEmpty || title.contains(query) || author.contains(query);

      final matchesStatus =
          _selectedStatus == null || book.status == _selectedStatus;

      final matchesOwnership =
          _selectedOwnershipType == null ||
          book.ownershipType == _selectedOwnershipType;

      return matchesSearch && matchesStatus && matchesOwnership;
    }).toList();
  }

  Future<void> _openMyRequests() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MyBorrowRequestsScreen()));
  }

  Future<void> _openIncomingRequests() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const IncomingBorrowRequestsScreen()),
    );
  }

  Widget _buildSessionCard(AuthSession? session) {
    final l10n = AppLocalizations.of(context)!;
    final name = session?.displayName ?? 'Authenticated user';
    final email = session?.email;
    final userId = session?.userId;
    final role = session?.role;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Signed in', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(name, style: Theme.of(context).textTheme.bodyLarge),
            if (email != null && email.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(email),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (userId != null)
                  _InfoChip(label: 'User #$userId', icon: Icons.badge_outlined),
                if (role != null && role.trim().isNotEmpty)
                  _InfoChip(label: role, icon: Icons.verified_user_outlined),
                const _InfoChip(
                  label: 'Session restored from local storage',
                  icon: Icons.lock_outline,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _openMyRequests,
                  icon: const Icon(Icons.outgoing_mail),
                  label: Text(l10n.navMyRequests),
                ),
                OutlinedButton.icon(
                  onPressed: _openIncomingRequests,
                  icon: const Icon(Icons.inbox_outlined),
                  label: Text(l10n.navIncomingRequests),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: l10n.booksSearchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String?>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  labelText: l10n.filterStatus,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.allStatuses),
                  ),
                  ..._statusOptions.map(
                    (status) => DropdownMenuItem<String?>(
                      value: status,
                      child: Text(BookUiLabels.status(status, l10n)),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String?>(
                initialValue: _selectedOwnershipType,
                decoration: InputDecoration(
                  labelText: l10n.filterOwnership,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.allOwnershipTypes),
                  ),
                  ..._ownershipOptions.map(
                    (ownershipType) => DropdownMenuItem<String?>(
                      value: ownershipType,
                      child: Text(
                        BookUiLabels.ownershipType(ownershipType, l10n),
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedOwnershipType = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.filter_alt_off),
            label: Text(l10n.clearFilters),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        children: [
          const Icon(Icons.menu_book_outlined, size: 48),
          const SizedBox(height: 12),
          Text(l10n.noBooksFound, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all),
            label: Text(l10n.clearFilters),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, Object error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.error_outline,
          size: 56,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.failedToLoadBooks(error.toString()),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: _reloadBooks,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(List<Book> books, AppLocalizations l10n) {
    final filteredBooks = _applyFilters(books);
    final session = CommunityBookExchangeApp.of(context)?.currentSession;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _buildSessionCard(session),
        const SizedBox(height: 12),
        _buildSearchField(l10n),
        const SizedBox(height: 12),
        _buildFilters(l10n),
        const SizedBox(height: 16),
        if (filteredBooks.isEmpty)
          _buildEmptyState(l10n)
        else
          ...filteredBooks.map(
            (book) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BookCard(
                book: book,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookDetailScreen(bookId: book.bookId),
                    ),
                  );

                  if (!mounted) {
                    return;
                  }

                  await _reloadBooks();
                },
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_booksFuture == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookListTitle),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
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
            return RefreshIndicator(
              onRefresh: _reloadBooks,
              child: _buildErrorState(l10n, snapshot.error!),
            );
          }

          final books = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _reloadBooks,
            child: _buildContent(books, l10n),
          );
        },
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _BookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authorText = (book.author != null && book.author!.trim().isNotEmpty)
        ? book.author!
        : l10n.unknownAuthor;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: const Icon(Icons.book_outlined),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authorText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          label: BookUiLabels.status(book.status, l10n),
                          icon: Icons.info_outline,
                        ),
                        _InfoChip(
                          label: BookUiLabels.ownershipType(
                            book.ownershipType,
                            l10n,
                          ),
                          icon: Icons.person_outline,
                        ),
                        if (book.overdue)
                          _InfoChip(
                            label: l10n.overdueBadge,
                            icon: Icons.warning_amber_rounded,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
