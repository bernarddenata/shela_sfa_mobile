import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/sync_item.dart';
import '../../../data/repositories/app_state_scope.dart';
import '../../../data/repositories/mock_sfa_repository.dart';

class SyncDetailPage extends StatefulWidget {
  const SyncDetailPage({required this.syncItemId, super.key});

  final String syncItemId;

  @override
  State<SyncDetailPage> createState() => _SyncDetailPageState();
}

class _SyncDetailPageState extends State<SyncDetailPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final item = repository.getSyncItemById(widget.syncItemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sync Detail')),
        body: const Center(child: Text('Sync item was not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Detail')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StatusChip(
                      label: item.status.label,
                      color: _detailStatusColor(item.status),
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(label: 'Type', value: item.type.label),
                    _InfoRow(label: 'Description', value: item.description),
                    _InfoRow(label: 'Reference ID', value: item.referenceId),
                    _InfoRow(
                      label: 'Created',
                      value: DateFormatters.dateTime(item.createdAt),
                    ),
                    _InfoRow(
                      label: 'Synced',
                      value: item.syncedAt == null
                          ? '-'
                          : DateFormatters.dateTime(item.syncedAt!),
                    ),
                    _InfoRow(
                      label: 'Customer',
                      value: _relatedCustomerName(repository, item),
                    ),
                    if (item.errorMessage != null)
                      _InfoRow(label: 'Error', value: item.errorMessage!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (item.status == SyncStatus.failed)
              FilledButton.icon(
                onPressed: _busy ? null : () => _retry(item.id),
                icon: const Icon(Icons.refresh_outlined),
                label: Text(_busy ? 'Retrying...' : 'Retry'),
              ),
            if (item.status == SyncStatus.queued) ...[
              OutlinedButton.icon(
                onPressed: () => _cancel(item.id),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Sync'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cancel only changes sync status. Local transaction data is kept.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _retry(String syncItemId) async {
    setState(() => _busy = true);
    final ok = await AppStateScope.of(context).retrySyncItem(syncItemId);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Sync item retried.' : 'Unable to retry.')),
    );
  }

  void _cancel(String syncItemId) {
    final ok = AppStateScope.of(context).cancelQueuedSyncItem(syncItemId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Sync item cancelled.' : 'Unable to cancel.'),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

String _relatedCustomerName(MockSfaRepository repository, SyncItem item) {
  final description = item.description.trim();
  return description.isEmpty ? '-' : description;
}

Color _detailStatusColor(SyncStatus status) {
  return switch (status) {
    SyncStatus.synced => AppTheme.accent,
    SyncStatus.failed => AppTheme.danger,
    SyncStatus.conflict || SyncStatus.cancelled => AppTheme.danger,
    SyncStatus.syncing => AppTheme.primary,
    SyncStatus.queued || SyncStatus.draft => AppTheme.warning,
  };
}
