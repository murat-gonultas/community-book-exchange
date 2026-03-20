import 'package:flutter/material.dart';

import '../data/book_api_service.dart';
import '../data/book_models.dart';

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

  Future<void> _runAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
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
      ).showSnackBar(SnackBar(content: Text('Action failed: $e')));
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  for (final entry in controllers.entries)
                    entry.key: entry.value.text.trim(),
                });
              },
              child: const Text('Submit'),
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
    final values = await _showActionDialog(
      title: 'Reserve Book',
      fields: const [
        _DialogFieldConfig(
          key: 'reservedForUserId',
          label: 'Reserved For User ID',
          isNumber: true,
        ),
        _DialogFieldConfig(
          key: 'reservedDays',
          label: 'Reserved Days',
          isNumber: true,
        ),
        _DialogFieldConfig(key: 'note', label: 'Note'),
      ],
    );

    if (values == null) return;

    final reservedForUserId = int.tryParse(values['reservedForUserId'] ?? '');
    final reservedDays = int.tryParse(values['reservedDays'] ?? '');

    if (reservedForUserId == null || reservedDays == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    await _runAction(
      () => _apiService.reserveBook(
        bookId: widget.bookId,
        reservedForUserId: reservedForUserId,
        reservedDays: reservedDays,
        note: values['note'],
      ),
      'Book reserved successfully',
    );
  }

  Future<void> _loanBook() async {
    final values = await _showActionDialog(
      title: 'Loan Book',
      fields: const [
        _DialogFieldConfig(
          key: 'loanedToUserId',
          label: 'Loaned To User ID',
          isNumber: true,
        ),
        _DialogFieldConfig(key: 'loanDays', label: 'Loan Days', isNumber: true),
        _DialogFieldConfig(key: 'note', label: 'Note'),
      ],
    );

    if (values == null) return;

    final loanedToUserId = int.tryParse(values['loanedToUserId'] ?? '');
    final loanDays = int.tryParse(values['loanDays'] ?? '');

    if (loanedToUserId == null || loanDays == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    await _runAction(
      () => _apiService.loanBook(
        bookId: widget.bookId,
        loanedToUserId: loanedToUserId,
        loanDays: loanDays,
        note: values['note'],
      ),
      'Book loaned successfully',
    );
  }

  Future<void> _returnBook() async {
    final values = await _showActionDialog(
      title: 'Return Book',
      fields: const [
        _DialogFieldConfig(
          key: 'returnedByUserId',
          label: 'Returned By User ID',
          isNumber: true,
        ),
        _DialogFieldConfig(key: 'note', label: 'Note'),
      ],
    );

    if (values == null) return;

    final returnedByUserId = int.tryParse(values['returnedByUserId'] ?? '');

    if (returnedByUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid user ID')),
      );
      return;
    }

    await _runAction(
      () => _apiService.returnBook(
        bookId: widget.bookId,
        returnedByUserId: returnedByUserId,
        note: values['note'],
      ),
      'Book returned successfully',
    );
  }

  Future<void> _giftBook() async {
    final values = await _showActionDialog(
      title: 'Gift Book',
      fields: const [
        _DialogFieldConfig(
          key: 'newOwnerUserId',
          label: 'New Owner User ID',
          isNumber: true,
        ),
        _DialogFieldConfig(key: 'note', label: 'Note'),
      ],
    );

    if (values == null) return;

    final newOwnerUserId = int.tryParse(values['newOwnerUserId'] ?? '');

    if (newOwnerUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid user ID')),
      );
      return;
    }

    await _runAction(
      () => _apiService.giftBook(
        bookId: widget.bookId,
        newOwnerUserId: newOwnerUserId,
        note: values['note'],
      ),
      'Book gifted successfully',
    );
  }

  Future<void> _donateBook() async {
    final values = await _showActionDialog(
      title: 'Donate Book',
      fields: const [
        _DialogFieldConfig(
          key: 'communityId',
          label: 'Community ID',
          isNumber: true,
        ),
        _DialogFieldConfig(key: 'note', label: 'Note'),
      ],
    );

    if (values == null) return;

    final communityId = int.tryParse(values['communityId'] ?? '');

    if (communityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid community ID')),
      );
      return;
    }

    await _runAction(
      () => _apiService.donateBook(
        bookId: widget.bookId,
        communityId: communityId,
        note: values['note'],
      ),
      'Book donated successfully',
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

  Widget _buildTransactionCard(BookTransaction tx) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tx.type, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('ID: ${tx.id}'),
            Text('From User: ${tx.fromUserId?.toString() ?? '-'}'),
            Text('To User: ${tx.toUserId?.toString() ?? '-'}'),
            Text('Start: ${tx.startDate ?? '-'}'),
            Text('End: ${tx.endDate ?? '-'}'),
            Text('Note: ${tx.note ?? '-'}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book #${widget.bookId}')),
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
                      'Failed to load book detail.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _reload,
                      child: const Text('Retry'),
                    ),
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
                _infoRow('Author', book.author ?? '-'),
                _infoRow('ISBN', book.isbn ?? '-'),
                _infoRow('Language', book.language ?? '-'),
                _infoRow('Category', book.category ?? '-'),
                _infoRow('Condition', book.condition ?? '-'),
                _infoRow('Notes', book.notes ?? '-'),
                _infoRow('Status', book.status),
                _infoRow('Ownership Type', book.ownershipType),
                _infoRow('Owner User ID', book.ownerUserId?.toString() ?? '-'),
                _infoRow(
                  'Owner Community ID',
                  book.ownerCommunityId?.toString() ?? '-',
                ),
                _infoRow(
                  'Current Holder User ID',
                  book.currentHolderUserId?.toString() ?? '-',
                ),
                _infoRow(
                  'Reserved For User ID',
                  book.reservedForUserId?.toString() ?? '-',
                ),
                _infoRow('Reserved Until', book.reservedUntil ?? '-'),
                _infoRow('Loan Start', book.loanStartAt ?? '-'),
                _infoRow('Due At', book.dueAt ?? '-'),
                const SizedBox(height: 24),
                Text('Actions', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: _reserveBook,
                      child: const Text('Reserve'),
                    ),
                    ElevatedButton(
                      onPressed: _loanBook,
                      child: const Text('Loan'),
                    ),
                    ElevatedButton(
                      onPressed: _returnBook,
                      child: const Text('Return'),
                    ),
                    ElevatedButton(
                      onPressed: _giftBook,
                      child: const Text('Gift'),
                    ),
                    ElevatedButton(
                      onPressed: _donateBook,
                      child: const Text('Donate'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (book.transactions.isEmpty)
                  const Text('No transactions')
                else
                  ...book.transactions.map(_buildTransactionCard),
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
