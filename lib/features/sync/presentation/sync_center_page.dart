import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/summary_card.dart';
import '../../../data/models/sync_item.dart';
import '../../../data/repositories/app_state_scope.dart';

enum SyncTypeFilter {
  all('ALL'),
  visit('VISIT'),
  order('ORDER'),
  returnActivity('RETURN'),
  promo('PROMO'),
  competitor('COMPETITOR'),
  planogram('PLANOGRAM'),
  stock('STOCK'),
  photo('PHOTO'),
  note('NOTE');

  const SyncTypeFilter(this.label);

  final String label;
}

enum SyncStatusFilter {
  all('ALL'),
  queued('QUEUED'),
  synced('SYNCED'),
  failed('FAILED'),
  conflict('CONFLICT');

  const SyncStatusFilter(this.label);

  final String label;
}

class SyncCenterPage extends StatefulWidget {
  const SyncCenterPage({super.key});

  @override
  State<SyncCenterPage> createState() => _SyncCenterPageState();
}

class _SyncCenterPageState extends State<SyncCenterPage> {
  SyncTypeFilter _typeFilter = SyncTypeFilter.all;
  SyncStatusFilter _statusFilter = SyncStatusFilter.all;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final summary = repository.getSyncCenterSnapshot();
    final items = repository.getSyncItems().where(_matchesFilters).toList();
    final allItems = repository.getSyncItems();

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Center')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.28,
              children: [
                SummaryCard(
                  title: 'Pending Sync',
                  value: summary.pendingSync.toString(),
                  icon: Icons.outbox_outlined,
                  color: AppTheme.warning,
                ),
                SummaryCard(
                  title: 'Synced Today',
                  value: summary.syncedToday.toString(),
                  icon: Icons.cloud_done_outlined,
                  color: AppTheme.accent,
                ),
                SummaryCard(
                  title: 'Failed Sync',
                  value: summary.failedSync.toString(),
                  icon: Icons.error_outline,
                  color: AppTheme.danger,
                ),
                SummaryCard(
                  title: 'Last Sync',
                  value: DateFormatters.shortTime(summary.lastSyncAt),
                  icon: Icons.sync,
                  color: AppTheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: _busy ? null : _syncNow,
                  icon: const Icon(Icons.sync),
                  label: Text(_busy ? 'Syncing...' : 'Sync Now'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _retryFailed,
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('Retry Failed'),
                ),
                if (allItems.any((item) => item.status == SyncStatus.synced))
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _clearSynced,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Synced'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: const Text(
                'Demo tools',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text('Use only for manual review scenarios.'),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _simulateFailed,
                    icon: const Icon(Icons.bug_report_outlined),
                    label: const Text('Simulate Failed Sync'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _FilterSection(
              title: 'Type',
              children: SyncTypeFilter.values
                  .map(
                    (filter) => FilterChip(
                      label: Text(filter.label),
                      selected: _typeFilter == filter,
                      onSelected: (_) => setState(() => _typeFilter = filter),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            _FilterSection(
              title: 'Status',
              children: SyncStatusFilter.values
                  .map(
                    (filter) => FilterChip(
                      label: Text(filter.label),
                      selected: _statusFilter == filter,
                      onSelected: (_) => setState(() => _statusFilter = filter),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            if (allItems.isEmpty)
              const _EmptyState(message: 'No sync items yet.')
            else if (items.isEmpty)
              const _EmptyState(message: 'No sync items match this filter.')
            else ...[
              if (allItems.every((item) => item.status == SyncStatus.synced))
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: _EmptyState(message: 'All data is synced.'),
                ),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SyncItemCard(item: item),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _matchesFilters(SyncItem item) {
    final typeMatches =
        _typeFilter == SyncTypeFilter.all ||
        _typeFilterFor(item.type) == _typeFilter;
    final statusMatches =
        _statusFilter == SyncStatusFilter.all ||
        _statusFilterFor(item.status) == _statusFilter;
    return typeMatches && statusMatches;
  }

  Future<void> _syncNow() async {
    setState(() => _busy = true);
    final count = await AppStateScope.of(context).syncQueuedItems();
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count == 0 ? 'No queued sync items.' : '$count item(s) synced.',
        ),
      ),
    );
  }

  Future<void> _retryFailed() async {
    setState(() => _busy = true);
    final count = await AppStateScope.of(context).retryFailedSyncItems();
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count == 0
              ? 'No failed sync items to retry.'
              : '$count failed item(s) retried.',
        ),
      ),
    );
  }

  void _simulateFailed() {
    final ok = AppStateScope.of(context).simulateFailedSync();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'One queued item was marked as failed.'
              : 'No queued sync item to fail.',
        ),
      ),
    );
  }

  void _clearSynced() {
    final ok = AppStateScope.of(context).clearSyncedSyncItems();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Synced items cleared.' : 'No synced items to clear.',
        ),
      ),
    );
  }
}

class _SyncItemCard extends StatelessWidget {
  const _SyncItemCard({required this.item});

  final SyncItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push(AppRoutes.syncDetailPath(item.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  StatusChip(
                    label: item.status.label,
                    color: _statusColor(item.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(item.description),
              const SizedBox(height: 8),
              Text(
                '${item.type.label} • Created ${DateFormatters.dateTime(item.createdAt)}',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (item.syncedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Synced ${DateFormatters.dateTime(item.syncedAt!)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

SyncTypeFilter _typeFilterFor(SyncItemType type) {
  return switch (type) {
    SyncItemType.visitCheckIn ||
    SyncItemType.visitCheckOut => SyncTypeFilter.visit,
    SyncItemType.regularOrder ||
    SyncItemType.canvasOrder => SyncTypeFilter.order,
    SyncItemType.returnOrder ||
    SyncItemType.returnSwapOrder => SyncTypeFilter.returnActivity,
    SyncItemType.promoCheck => SyncTypeFilter.promo,
    SyncItemType.competitorActivity => SyncTypeFilter.competitor,
    SyncItemType.planogramCheck => SyncTypeFilter.planogram,
    SyncItemType.stockCheck => SyncTypeFilter.stock,
    SyncItemType.storePhoto => SyncTypeFilter.photo,
    SyncItemType.visitNote => SyncTypeFilter.note,
  };
}

SyncStatusFilter? _statusFilterFor(SyncStatus status) {
  return switch (status) {
    SyncStatus.queued || SyncStatus.syncing => SyncStatusFilter.queued,
    SyncStatus.synced => SyncStatusFilter.synced,
    SyncStatus.failed => SyncStatusFilter.failed,
    SyncStatus.conflict => SyncStatusFilter.conflict,
    SyncStatus.draft || SyncStatus.cancelled => null,
  };
}

Color _statusColor(SyncStatus status) {
  return switch (status) {
    SyncStatus.synced => AppTheme.accent,
    SyncStatus.failed => AppTheme.danger,
    SyncStatus.conflict || SyncStatus.cancelled => AppTheme.danger,
    SyncStatus.syncing => AppTheme.primary,
    SyncStatus.queued || SyncStatus.draft => AppTheme.warning,
  };
}
