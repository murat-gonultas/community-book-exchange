import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/generated/app_localizations.dart';

import '../../../main.dart';
import '../data/borrow_request_api_service.dart';
import '../data/borrow_request_models.dart';

class MyBorrowRequestsScreen extends StatefulWidget {
  const MyBorrowRequestsScreen({super.key});

  @override
  State<MyBorrowRequestsScreen> createState() => _MyBorrowRequestsScreenState();
}

class _MyBorrowRequestsScreenState extends State<MyBorrowRequestsScreen> {
  late BorrowRequestApiService _apiService;
  Future<List<BorrowRequestItem>>? _requestsFuture;
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final token = CommunityBookExchangeApp.of(context)?.currentSession?.token;
    _apiService = BorrowRequestApiService(bearerToken: token);

    if (!_didLoad) {
      _requestsFuture = _apiService.fetchMyRequests();
      _didLoad = true;
    }
  }

  Future<void> _reload() async {
    setState(() {
      _requestsFuture = _apiService.fetchMyRequests();
    });

    await _requestsFuture;
  }

  Future<bool> _confirmCancel(BorrowRequestItem item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel borrow request'),
          content: Text(
            'Do you really want to cancel the request for "${item.titleOrFallback}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, cancel'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _cancelRequest(BorrowRequestItem item) async {
    final confirmed = await _confirmCancel(item);

    if (!mounted) {
      return;
    }

    if (!confirmed) {
      return;
    }

    try {
      await _apiService.cancelBorrowRequest(borrowRequestId: item.requestId);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Borrow request cancelled successfully.')),
      );

      await _reload();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'REJECTED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      case 'FULFILLED':
        return Colors.green;
      default:
        return Colors.black54;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      case 'CANCELLED':
        return 'Cancelled';
      case 'FULFILLED':
        return 'Fulfilled';
      default:
        return status;
    }
  }

  Widget _infoRow(String label, String? value) {
    final display = (value == null || value.trim().isEmpty)
        ? '—'
        : value.trim();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(display)),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BorrowRequestItem item) {
    final statusColor = _statusColor(item.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.titleOrFallback,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (item.bookAuthor != null &&
                item.bookAuthor!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(item.bookAuthor!),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    _statusLabel(item.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (item.bookId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('Book #${item.bookId}'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow('Message', item.message),
            _infoRow('Rejection reason', item.rejectionReason),
            _infoRow('Decision note', item.decisionNote),
            _infoRow('Decided by', item.decidedByUserName),
            _infoRow('Decided at', item.decidedAt),
            _infoRow('Created at', item.createdAt),
            _infoRow('Updated at', item.updatedAt),
            if (item.isPending) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _cancelRequest(item),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel request'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: const [
        SizedBox(height: 60),
        Icon(Icons.inbox_outlined, size: 56),
        SizedBox(height: 16),
        Center(
          child: Text(
            'You do not have any borrow requests yet.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 60),
        Icon(
          Icons.error_outline,
          size: 56,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          'Failed to load your borrow requests.\n\n$error',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_requestsFuture == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Borrow Requests')),
      body: FutureBuilder<List<BorrowRequestItem>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: _buildErrorState(snapshot.error!),
            );
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: _buildEmptyState(),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(requests[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
