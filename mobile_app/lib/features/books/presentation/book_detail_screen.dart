import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/generated/app_localizations.dart';

import '../../../main.dart';
import '../../auth/data/auth_models.dart';
import '../../borrow_requests/data/borrow_request_api_service.dart';
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
  late BookApiService _apiService;
  late BorrowRequestApiService _borrowRequestApiService;

  Future<BookDetail>? _bookDetailFuture;
  Future<List<UserSummary>>? _usersFuture;
  Future<List<CommunitySummary>>? _communitiesFuture;

  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final token = CommunityBookExchangeApp.of(context)?.currentSession?.token;
    _apiService = BookApiService(bearerToken: token);
    _borrowRequestApiService = BorrowRequestApiService(bearerToken: token);

    if (!_didLoad) {
      _bookDetailFuture = _apiService.fetchBookDetail(widget.bookId);
      _usersFuture = _apiService.fetchUsers();
      _communitiesFuture = _apiService.fetchCommunities();
      _didLoad = true;
    }
  }

  Future<void> _reload() async {
    setState(() {
      _bookDetailFuture = _apiService.fetchBookDetail(widget.bookId);
    });

    await _bookDetailFuture;
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

  Future<void> _runAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await action();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));

      await _reload();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.actionFailed(e.toString()))));
    }
  }

  Future<String?> _showTextInputDialog({
    required String title,
    required String label,
    String? submitLabel,
  }) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(submitLabel ?? 'Submit'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<Map<String, String>?> _showUserActionDialog({
    required String title,
    required String userFieldKey,
    required String userFieldLabel,
    required List<_DialogFieldConfig> extraFields,
    int? initialUserId,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    List<UserSummary> users;

    try {
      users = await _usersFuture!;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.actionFailed(e.toString()))),
        );
      }
      return null;
    }

    if (!mounted) {
      return null;
    }

    final controllers = {
      for (final field in extraFields) field.key: TextEditingController(),
    };

    int? selectedUserId =
        initialUserId ?? (users.isNotEmpty ? users.first.id : null);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: selectedUserId,
                      decoration: InputDecoration(
                        labelText: userFieldLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: users
                          .map(
                            (user) => DropdownMenuItem<int>(
                              value: user.id,
                              child: Text(user.displayLabel()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedUserId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ...extraFields.map((field) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: controllers[field.key],
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: field.label,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: selectedUserId == null
                      ? null
                      : () {
                          Navigator.of(context).pop({
                            userFieldKey: selectedUserId.toString(),
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
      },
    );

    for (final controller in controllers.values) {
      controller.dispose();
    }

    return result;
  }

  Future<Map<String, String>?> _showCommunityActionDialog({
    required String title,
    required String communityFieldKey,
    required String communityFieldLabel,
    required List<_DialogFieldConfig> extraFields,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    List<CommunitySummary> communities;

    try {
      communities = await _communitiesFuture!;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.actionFailed(e.toString()))),
        );
      }
      return null;
    }

    if (!mounted) {
      return null;
    }

    final controllers = {
      for (final field in extraFields) field.key: TextEditingController(),
    };

    int? selectedCommunityId = communities.isNotEmpty
        ? communities.first.id
        : null;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: selectedCommunityId,
                      decoration: InputDecoration(
                        labelText: communityFieldLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: communities
                          .map(
                            (community) => DropdownMenuItem<int>(
                              value: community.id,
                              child: Text(community.displayLabel()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCommunityId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ...extraFields.map((field) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: controllers[field.key],
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: field.label,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: selectedCommunityId == null
                      ? null
                      : () {
                          Navigator.of(context).pop({
                            communityFieldKey: selectedCommunityId.toString(),
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
      },
    );

    for (final controller in controllers.values) {
      controller.dispose();
    }

    return result;
  }

  Future<void> _createBorrowRequest(BookDetail book) async {
    final message = await _showTextInputDialog(
      title: 'Create borrow request',
      label: 'Message (optional)',
      submitLabel: 'Send request',
    );

    if (message == null) {
      return;
    }

    await _runAction(
      () => _borrowRequestApiService.createBorrowRequest(
        bookId: book.bookId,
        message: message,
      ),
      'Borrow request created successfully.',
    );
  }

  Future<void> _loanBook() async {
    final l10n = AppLocalizations.of(context)!;

    final values = await _showUserActionDialog(
      title: l10n.loanBook,
      userFieldKey: 'loanedToUserId',
      userFieldLabel: l10n.loanedToUserId,
      extraFields: [_DialogFieldConfig(key: 'note', label: l10n.note)],
    );

    if (!mounted || values == null) {
      return;
    }

    final loanedToUserId = int.tryParse(values['loanedToUserId'] ?? '');

    if (loanedToUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterValidUserId)));
      return;
    }

    await _runAction(
      () => _apiService.loanBook(
        bookId: widget.bookId,
        loanedToUserId: loanedToUserId,
        note: values['note'],
      ),
      l10n.bookLoanedSuccessfully,
    );
  }

  Future<void> _extendLoan() async {
    final currentUserId = _currentUserId;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be signed in to extend a loan.'),
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    await _runAction(() async {
      await _apiService.extendLoan(
        bookId: widget.bookId,
        requesterUserId: currentUserId,
      );
    }, l10n.bookExtendedSuccessfully);
  }

  Future<void> _returnBook() async {
    final l10n = AppLocalizations.of(context)!;

    final values = await _showUserActionDialog(
      title: l10n.returnBook,
      userFieldKey: 'returnedByUserId',
      userFieldLabel: l10n.returnedByUserId,
      extraFields: [_DialogFieldConfig(key: 'note', label: l10n.note)],
    );

    if (!mounted || values == null) {
      return;
    }

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

    final values = await _showUserActionDialog(
      title: l10n.giftBook,
      userFieldKey: 'newOwnerUserId',
      userFieldLabel: l10n.newOwnerUserId,
      extraFields: [_DialogFieldConfig(key: 'note', label: l10n.note)],
    );

    if (!mounted || values == null) {
      return;
    }

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

    final values = await _showCommunityActionDialog(
      title: l10n.donateBook,
      communityFieldKey: 'communityId',
      communityFieldLabel: l10n.communityId,
      extraFields: [_DialogFieldConfig(key: 'note', label: l10n.note)],
    );

    if (!mounted || values == null) {
      return;
    }

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

  int? get _currentUserId {
    return CommunityBookExchangeApp.of(context)?.currentUserId;
  }

  AuthSession? get _currentSession {
    return CommunityBookExchangeApp.of(context)?.currentSession;
  }

  List<String> _getActionHints(
    BookDetail book,
    AppLocalizations l10n,
    int? currentUserId,
  ) {
    final hints = <String>[];

    final availableStatus = BookUiLabels.status('AVAILABLE', l10n);
    final onLoanStatus = BookUiLabels.status('ON_LOAN', l10n);
    final userOwnership = BookUiLabels.ownershipType('USER', l10n);

    if (!BookActionRules.canCreateBorrowRequest(book, currentUserId)) {
      if (currentUserId == null) {
        hints.add('You must be signed in to create a borrow request.');
      } else if (book.status != 'AVAILABLE') {
        hints.add('Borrow requests can only be created for available books.');
      } else if (book.ownerUserId != null &&
          book.ownerUserId == currentUserId) {
        hints.add('You cannot create a borrow request for your own book.');
      }
    }

    if (!BookActionRules.canLoan(book)) {
      hints.add(l10n.hintLoanUnavailable(availableStatus));
    }

    if (!BookActionRules.canReturn(book)) {
      hints.add(l10n.hintReturnUnavailable(onLoanStatus));
    }

    if (!BookActionRules.canGift(book)) {
      hints.add(l10n.hintGiftUnavailable(userOwnership));
    }

    if (!BookActionRules.canDonate(book)) {
      hints.add(l10n.hintDonateUnavailable(userOwnership));
    }

    if (!BookActionRules.canExtend(book, currentUserId)) {
      if (currentUserId == null) {
        hints.add('Loan extension needs a signed-in user context.');
      } else if (book.status != 'ON_LOAN') {
        hints.add(l10n.hintExtendUnavailableNotOnLoan(onLoanStatus));
      } else if (book.overdue) {
        hints.add(l10n.hintExtendUnavailableOverdue);
      } else if ((book.loanExtendedCount ?? 0) >= 2) {
        hints.add(l10n.hintExtendUnavailableMaxReached);
      } else if (book.currentHolderUserId != currentUserId) {
        hints.add('Only the current holder can extend this loan.');
      }
    }

    return hints;
  }

  Widget _buildActionHints(
    BookDetail book,
    AppLocalizations l10n,
    int? currentUserId,
  ) {
    final hints = _getActionHints(book, l10n, currentUserId);

    if (hints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget _buildBadge({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)],
      ),
    );
  }

  Widget _buildHeaderCard(BookDetail book, AppLocalizations l10n) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            book.author ?? l10n.notAvailable,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                context: context,
                icon: Icons.info_outline,
                label: BookUiLabels.status(book.status, l10n),
              ),
              _buildBadge(
                context: context,
                icon: Icons.person_outline,
                label: BookUiLabels.ownershipType(book.ownershipType, l10n),
              ),
              if (book.overdue)
                _buildBadge(
                  context: context,
                  icon: Icons.warning_amber_rounded,
                  label: l10n.overdueBadge,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfoCard() {
    final session = _currentSession;

    if (session == null) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Signed in as', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(session.displayName),
          if (session.email != null && session.email!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(session.email!),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (session.userId != null)
                _buildBadge(
                  context: context,
                  icon: Icons.badge_outlined,
                  label: 'User #${session.userId}',
                ),
              if (session.role != null && session.role!.trim().isNotEmpty)
                _buildBadge(
                  context: context,
                  icon: Icons.verified_user_outlined,
                  label: session.role!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BookDetail book, AppLocalizations l10n) {
    return _buildSectionCard(
      child: Column(
        children: [
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
          _infoRow(l10n.loanStart, book.loanStartAt ?? l10n.notAvailable),
          _infoRow(l10n.dueAt, book.dueAt ?? l10n.notAvailable),
          _infoRow(l10n.loanExtendedCount, '${book.loanExtendedCount ?? 0}/2'),
          if (book.overdue)
            _infoRow(l10n.overdueDaysLabel, book.overdueDays.toString()),
        ],
      ),
    );
  }

  Widget _buildOverdueCard(BookDetail book, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.bookOverdueMessage(book.overdueDays),
              style: TextStyle(color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BookTransaction tx, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              BookUiLabels.transactionType(tx.type, l10n),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _infoRow(l10n.idLabel, tx.id.toString()),
            _infoRow(
              l10n.fromUser,
              tx.fromUserId?.toString() ?? l10n.notAvailable,
            ),
            _infoRow(l10n.toUser, tx.toUserId?.toString() ?? l10n.notAvailable),
            _infoRow(l10n.start, tx.startDate ?? l10n.notAvailable),
            _infoRow(l10n.end, tx.endDate ?? l10n.notAvailable),
            _infoRow(l10n.note, tx.note ?? l10n.notAvailable),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _buildActionsCard(
    BookDetail book,
    AppLocalizations l10n,
    int? currentUserId,
  ) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.actions, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton(
                label: 'Borrow request',
                enabled: BookActionRules.canCreateBorrowRequest(
                  book,
                  currentUserId,
                ),
                onPressed: () => _createBorrowRequest(book),
                icon: Icons.send_outlined,
              ),
              _buildActionButton(
                label: l10n.loan,
                enabled: BookActionRules.canLoan(book),
                onPressed: _loanBook,
                icon: Icons.swap_horiz,
              ),
              _buildActionButton(
                label: l10n.returnAction,
                enabled: BookActionRules.canReturn(book),
                onPressed: _returnBook,
                icon: Icons.assignment_return_outlined,
              ),
              _buildActionButton(
                label: l10n.extendLoan,
                enabled: BookActionRules.canExtend(book, currentUserId),
                onPressed: _extendLoan,
                icon: Icons.update,
              ),
              _buildActionButton(
                label: l10n.gift,
                enabled: BookActionRules.canGift(book),
                onPressed: _giftBook,
                icon: Icons.redeem_outlined,
              ),
              _buildActionButton(
                label: l10n.donate,
                enabled: BookActionRules.canDonate(book),
                onPressed: _donateBook,
                icon: Icons.volunteer_activism_outlined,
              ),
            ],
          ),
          _buildActionHints(book, l10n, currentUserId),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(BookDetail book, AppLocalizations l10n) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.transactions,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (book.transactions.isEmpty)
            Text(l10n.noTransactions)
          else
            ...book.transactions.map((tx) => _buildTransactionCard(tx, l10n)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_bookDetailFuture == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentUserId = _currentUserId;

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
                _buildHeaderCard(book, l10n),
                const SizedBox(height: 16),
                _buildSessionInfoCard(),
                const SizedBox(height: 16),
                _buildDetailsCard(book, l10n),
                if (book.overdue) ...[
                  const SizedBox(height: 16),
                  _buildOverdueCard(book, l10n),
                ],
                const SizedBox(height: 16),
                _buildActionsCard(book, l10n, currentUserId),
                const SizedBox(height: 16),
                _buildTransactionsSection(book, l10n),
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

  const _DialogFieldConfig({required this.key, required this.label});
}

class BookActionRules {
  static bool canCreateBorrowRequest(BookDetail book, int? currentUserId) {
    return currentUserId != null &&
        book.status == 'AVAILABLE' &&
        book.ownerUserId != currentUserId;
  }

  static bool canLoan(BookDetail book) {
    return book.status == 'AVAILABLE';
  }

  static bool canReturn(BookDetail book) {
    return book.status == 'ON_LOAN';
  }

  static bool canGift(BookDetail book) {
    return book.ownershipType == 'USER';
  }

  static bool canDonate(BookDetail book) {
    return book.ownershipType == 'USER';
  }

  static bool canExtend(BookDetail book, int? currentUserId) {
    return currentUserId != null &&
        book.status == 'ON_LOAN' &&
        book.currentHolderUserId == currentUserId &&
        !book.overdue &&
        (book.loanExtendedCount ?? 0) < 2;
  }
}
