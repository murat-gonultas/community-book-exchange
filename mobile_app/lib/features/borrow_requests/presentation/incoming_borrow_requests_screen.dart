import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/generated/app_localizations.dart';

import '../../../main.dart';
import '../data/borrow_request_api_service.dart';
import '../data/borrow_request_models.dart';

class IncomingBorrowRequestsScreen extends StatefulWidget {
  const IncomingBorrowRequestsScreen({super.key});

  @override
  State<IncomingBorrowRequestsScreen> createState() =>
      _IncomingBorrowRequestsScreenState();
}

class _IncomingBorrowRequestsScreenState
    extends State<IncomingBorrowRequestsScreen> {
  late BorrowRequestApiService _apiService;
  Future<List<BorrowRequestItem>>? _requestsFuture;
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final token = CommunityBookExchangeApp.of(context)?.currentSession?.token;
    _apiService = BorrowRequestApiService(bearerToken: token);

    if (!_didLoad) {
      _requestsFuture = _apiService.fetchIncomingRequests();
      _didLoad = true;
    }
  }

  Future<void> _reload() async {
    setState(() {
      _requestsFuture = _apiService.fetchIncomingRequests();
    });

    await _requestsFuture;
  }

  Future<String?> _showSingleTextDialog({
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
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(submitLabel ?? AppLocalizations.of(context)!.submit),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<Map<String, String>?> _showRejectDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();
    final noteController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.borrowRequestRejectTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Rejection reason',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Decision note (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'rejectionReason': reasonController.text.trim(),
                  'decisionNote': noteController.text.trim(),
                });
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    reasonController.dispose();
    noteController.dispose();
    return result;
  }

  Future<void> _approveRequest(BorrowRequestItem item) async {
    final l10n = AppLocalizations.of(context)!;

    final decisionNote = await _showSingleTextDialog(
      title: l10n.borrowRequestApproveTitle,
      label: 'Decision note (optional)',
      submitLabel: 'Approve',
    );

    if (!mounted) {
      return;
    }

    if (decisionNote == null) {
      return;
    }

    try {
      await _apiService.approveBorrowRequest(
        borrowRequestId: item.requestId,
        decisionNote: decisionNote,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.borrowRequestApprovedSuccess)),
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

  Future<void> _rejectRequest(BorrowRequestItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final values = await _showRejectDialog();

    if (!mounted) {
      return;
    }

    if (values == null) {
      return;
    }

    final rejectionReason = (values['rejectionReason'] ?? '').trim();
    final decisionNote = (values['decisionNote'] ?? '').trim();

    if (rejectionReason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rejection reason is required.')),
      );
      return;
    }

    try {
      await _apiService.rejectBorrowRequest(
        borrowRequestId: item.requestId,
        rejectionReason: rejectionReason,
        decisionNote: decisionNote,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.borrowRequestRejectedSuccess)),
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

  Future<void> _fulfillRequest(BorrowRequestItem item) async {
    final l10n = AppLocalizations.of(context)!;

    final note = await _showSingleTextDialog(
      title: l10n.borrowRequestFulfillTitle,
      label: 'Loan note (optional)',
      submitLabel: 'Fulfill',
    );

    if (!mounted) {
      return;
    }

    if (note == null) {
      return;
    }

    try {
      await _apiService.fulfillBorrowRequest(
        borrowRequestId: item.requestId,
        note: note,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.borrowRequestFulfilledSuccess)),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(item.requesterLabel),
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
            if (item.isPending || item.isApproved) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (item.isPending)
                    FilledButton.icon(
                      onPressed: () => _approveRequest(item),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Approve'),
                    ),
                  if (item.isPending)
                    OutlinedButton.icon(
                      onPressed: () => _rejectRequest(item),
                      icon: const Icon(Icons.highlight_off),
                      label: const Text('Reject'),
                    ),
                  if (item.isApproved)
                    FilledButton.icon(
                      onPressed: () => _fulfillRequest(item),
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('Fulfill to loan'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 60),
        const Icon(Icons.move_to_inbox_outlined, size: 56),
        const SizedBox(height: 16),
        Center(
          child: Text(
            l10n.incomingBorrowRequestsEmpty,
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
          l10n.incomingBorrowRequestsLoadError(error.toString()),
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
    final l10n = AppLocalizations.of(context)!;

    if (_requestsFuture == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.incomingBorrowRequestsTitle)),
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
