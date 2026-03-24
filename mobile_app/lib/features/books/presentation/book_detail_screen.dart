import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/generated/app_localizations.dart';

import '../../../main.dart';
import '../data/book_api_service.dart';
import '../data/book_models.dart';
import 'book_ui_labels.dart';

class BookDetailScreen extends StatefulWidget {
  final int bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookApiService _apiService = BookApiService();
  late Future<BookDetail> _bookDetailFuture;

  @override
  void initState() {
    super.initState();
    _bookDetailFuture = _apiService.fetchBookDetail(widget.bookId);
  }

  Future<void> _reload() async {
    setState(() {
      _bookDetailFuture = _apiService.fetchBookDetail(widget.bookId);
    });
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

  Future<void> _runAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await action();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));

      await _reload();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.actionFailed(e.toString()))));
    }
  }

  Future<Map<String, String>?> _showActionDialog({
    required String title,
    required List<_DialogFieldConfig> fields,
  }) async {
    final controllers = {
      for (final field in fields) field.key: TextEditingController(),
    };

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields.map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: controllers[field.key],
                    keyboardType: field.isNumber
                        ? TextInputType.number
                        : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: field.label,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  for (final entry in controllers.entries)
                    entry.key: entry.value.text.trim(),
                });
              },
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        );
      },
    );

    for (final controller in controllers.values) {
      controller.dispose();
    }

    return result;
  }

  Future<void> _reserveBook() async {
    final l10n = AppLocalizations.of(context)!;

    final values = await _showActionDialog(
      title: l10n.reserveBook,
      fields: [
        _DialogFieldConfig(
          key: 'reservedForUserId',
          label: l10n.reservedForUserId,
          isNumber: true,
        ),
        _DialogFieldConfig(
          key: 'reservedDays',
          label: l10n.reservedDays,
          isNumber: true,
        ),
        _DialogFieldConfig(key: 'note', label: l10n.note),
      ],
    );

    if (values == null) return;

    final reservedForUserId = int.tryParse(values['reservedForUserId'] ?? '');
    final reservedDays = int.tryParse(values['reservedDays'] ?? '');

    if (reservedForUserId == null || reservedDays == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterValidNumbers)));
      return;
    }

    await _runAction(
      () => _apiService.reserveBook(
        bookId: widget.bookId,
        reservedForUserId: reservedForUserId,
        reservedDays: reservedDays,
        note: values['note'],
      ),
      l10n.bookReservedSuccessfully,
    );
  }

  Future<void> _loanBook() async {
    final l10n = AppLocalizations.of(context)!;

    final values = await _showActionDialog(
      title: l10n.loanBook,
      fields: [
        _DialogFieldConfig(
          key: 'loanedToUserId',
          label: l10n.loanedToUserId,
          isNumber: true,
        ),
        _DialogFieldConfig(
          key: 'loanDays',
          label: l10n.loanDays,
          isNumber: true,
        ),
        _DialogFieldConfig(key: 'note', label: l10n.note),
      ],
    );

    if (values == null) return;

    final loanedToUserId = int.tryParse(values['loanedToUserId'] ?? '');
    final loanDays = int.tryParse(values['loanDays'] ?? '');

    if (loanedToUserId == null || loanDays == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterValidNumbers)));
      return;
    }

    await _runAction(
      () => _apiService.loanBook(
        bookId: widget.bookId,
        loanedToUserId: loanedToUserId,
        loanDays: loanDays,
        note: values['note'],
      ),
      l10n.bookLoanedSuccessfully,
    );
  }

  Future<void> _returnBook() async {
    final l10n = AppLocalizations.of(context)!;

    final values = await _showActionDialog(
      title: l10n.returnBook,
      fields: [
        _DialogFieldConfig(
          key: 'returnedByUserId',
          label: l10n.returnedByUserId,
          isNumber: true,
        ),
        _DialogFieldConfig(key: 'note', label: l10n.note),
      ],
    );

    if (values == null) return;

    final returnedByUserId = int.tryParse(values['returnedByUserId'] ?? '');

    if (returnedByUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterValidUserId)));
      return;
    }

    await _runAction(
      () => _apiService.returnBook(
        bookId: widget.bookId,
        returnedByUserId: returnedByUserId,
        note: values['note'],
      ),
      l10n.bookReturnedSuccessfully,
    );
  }

  Future<void> _giftBook() async {
    final l10n = AppLocalizations.of(context)!;

    final values = await _showActionDialog(
      title: l10n.giftBook,
      fields: [
        _DialogFieldConfig(
          key: 'newOwnerUserId',
          label: l10n.newOwnerUserId,
          isNumber: true,
        ),
        _DialogFieldConfig(key: 'note', label: l10n.note),
      ],
    );

    if (values == null) return;

    final newOwnerUserId = int.tryParse(values['newOwnerUserId'] ?? '');

    if (newOwnerUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterValidUserId)));
      return;
    }

    await _runAction(
      () => _apiService.giftBook(
        bookId: widget.bookId,
        newOwnerUserId: newOwnerUserId,
        note: values['note'],
      ),
      l10n.bookGiftedSuccessfully,
    );
  }

  Future<void> _donateBook() async {
    final l10n = AppLocalizations.of(context)!;

    final values = await _showActionDialog(
      title: l10n.donateBook,
      fields: [
        _DialogFieldConfig(
          key: 'communityId',
          label: l10n.communityId,
          isNumber: true,
        ),
        _DialogFieldConfig(key: 'note', label: l10n.note),
      ],
    );

    if (values == null) return;

    final communityId = int.tryParse(values['communityId'] ?? '');

    if (communityId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterValidCommunityId)));
      return;
    }

    await _runAction(
      () => _apiService.donateBook(
        bookId: widget.bookId,
        communityId: communityId,
        note: values['note'],
      ),
      l10n.bookDonatedSuccessfully,
    );
  }

  List<String> _getActionHints(BookDetail book, AppLocalizations l10n) {
    final hints = <String>[];

    if (!BookActionRules.canReserve(book)) {
      hints.add(l10n.hintReserveUnavailable);
    }

    if (!BookActionRules.canLoan(book)) {
      hints.add(l10n.hintLoanUnavailable);
    }

    if (!BookActionRules.canReturn(book)) {
      hints.add(l10n.hintReturnUnavailable);
    }

    if (!BookActionRules.canGift(book)) {
      hints.add(l10n.hintGiftUnavailable);
    }

    if (!BookActionRules.canDonate(book)) {
      hints.add(l10n.hintDonateUnavailable);
    }

    if (book.status == 'RESERVED') {
      hints.add(l10n.hintReservedLoanRule);
    }

    return hints;
  }

  Widget _buildActionHints(BookDetail book, AppLocalizations l10n) {
    final hints = _getActionHints(book, l10n);

    if (hints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whyActionsUnavailable,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...hints.map(
            (hint) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $hint',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BookTransaction tx, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              BookUiLabels.transactionType(tx.type, l10n),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('${l10n.idLabel}: ${tx.id}'),
            Text(
              '${l10n.fromUser}: ${tx.fromUserId?.toString() ?? l10n.notAvailable}',
            ),
            Text(
              '${l10n.toUser}: ${tx.toUserId?.toString() ?? l10n.notAvailable}',
            ),
            Text('${l10n.start}: ${tx.startDate ?? l10n.notAvailable}'),
            Text('${l10n.end}: ${tx.endDate ?? l10n.notAvailable}'),
            Text('${l10n.note}: ${tx.note ?? l10n.notAvailable}'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookTitleWithId(widget.bookId)),
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
      body: FutureBuilder<BookDetail>(
        future: _bookDetailFuture,
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
                      l10n.failedToLoadBookDetail(snapshot.error.toString()),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _reload, child: Text(l10n.retry)),
                  ],
                ),
              ),
            );
          }

          final book = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                _infoRow(l10n.author, book.author ?? l10n.notAvailable),
                _infoRow(l10n.isbn, book.isbn ?? l10n.notAvailable),
                _infoRow(l10n.language, book.language ?? l10n.notAvailable),
                _infoRow(l10n.category, book.category ?? l10n.notAvailable),
                _infoRow(l10n.condition, book.condition ?? l10n.notAvailable),
                _infoRow(l10n.notes, book.notes ?? l10n.notAvailable),
                _infoRow(l10n.status, BookUiLabels.status(book.status, l10n)),
                _infoRow(
                  l10n.ownershipType,
                  BookUiLabels.ownershipType(book.ownershipType, l10n),
                ),
                _infoRow(
                  l10n.ownerUserId,
                  book.ownerUserId?.toString() ?? l10n.notAvailable,
                ),
                _infoRow(
                  l10n.ownerCommunityId,
                  book.ownerCommunityId?.toString() ?? l10n.notAvailable,
                ),
                _infoRow(
                  l10n.currentHolderUserId,
                  book.currentHolderUserId?.toString() ?? l10n.notAvailable,
                ),
                _infoRow(
                  l10n.reservedForUserIdLabel,
                  book.reservedForUserId?.toString() ?? l10n.notAvailable,
                ),
                _infoRow(
                  l10n.reservedUntil,
                  book.reservedUntil ?? l10n.notAvailable,
                ),
                _infoRow(l10n.loanStart, book.loanStartAt ?? l10n.notAvailable),
                _infoRow(l10n.dueAt, book.dueAt ?? l10n.notAvailable),
                const SizedBox(height: 24),
                Text(
                  l10n.actions,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildActionButton(
                      label: l10n.reserve,
                      enabled: BookActionRules.canReserve(book),
                      onPressed: _reserveBook,
                    ),
                    _buildActionButton(
                      label: l10n.loan,
                      enabled: BookActionRules.canLoan(book),
                      onPressed: _loanBook,
                    ),
                    _buildActionButton(
                      label: l10n.returnAction,
                      enabled: BookActionRules.canReturn(book),
                      onPressed: _returnBook,
                    ),
                    _buildActionButton(
                      label: l10n.gift,
                      enabled: BookActionRules.canGift(book),
                      onPressed: _giftBook,
                    ),
                    _buildActionButton(
                      label: l10n.donate,
                      enabled: BookActionRules.canDonate(book),
                      onPressed: _donateBook,
                    ),
                  ],
                ),
                _buildActionHints(book, l10n),
                const SizedBox(height: 24),
                Text(
                  l10n.transactions,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (book.transactions.isEmpty)
                  Text(l10n.noTransactions)
                else
                  ...book.transactions.map(
                    (tx) => _buildTransactionCard(tx, l10n),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DialogFieldConfig {
  final String key;
  final String label;
  final bool isNumber;

  const _DialogFieldConfig({
    required this.key,
    required this.label,
    this.isNumber = false,
  });
}

class BookActionRules {
  static bool canReserve(BookDetail book) {
    return book.status == 'AVAILABLE';
  }

  static bool canLoan(BookDetail book) {
    return book.status == 'AVAILABLE' || book.status == 'RESERVED';
  }

  static bool canReturn(BookDetail book) {
    return book.status == 'ON_LOAN';
  }

  static bool canGift(BookDetail book) {
    return book.status == 'AVAILABLE' && book.ownershipType == 'USER';
  }

  static bool canDonate(BookDetail book) {
    return book.status == 'AVAILABLE' && book.ownershipType == 'USER';
  }
}
