import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/visit_note.dart';
import '../../../data/repositories/app_state_scope.dart';

class EndVisitPage extends StatelessWidget {
  const EndVisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final visit = repository.activeVisit;
    final customer = visit == null
        ? null
        : repository.getCustomerById(visit.customerId);

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('End Visit')),
        body: const Center(
          child: Text('Please check in before recording store activity.'),
        ),
      );
    }

    final summary = repository.getVisitSummary(visit.id);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('End Visit')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () =>
                _confirmEndVisit(context, summary.hasAnyStoreActivity),
            icon: const Icon(Icons.logout_outlined),
            label: const Text('Confirm End Visit'),
          ),
        ),
      ),
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
                      customer.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(customer.address),
                    const SizedBox(height: 12),
                    StatusChip(
                      label: visit.status.label,
                      color: AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (!summary.hasAnyStoreActivity) ...[
              const _WarningCard(
                message:
                    'No store activity recorded. You can still end this visit after confirmation.',
              ),
              const SizedBox(height: 12),
            ],
            _SummaryCard(
              title: 'Visit Time',
              rows: [
                _SummaryRow(
                  label: 'Check-in Time',
                  value: DateFormatters.dateTime(visit.checkInAt),
                ),
                _SummaryRow(
                  label: 'Check-out Preview',
                  value: DateFormatters.dateTime(now),
                ),
                _SummaryRow(
                  label: 'Visit Duration',
                  value: _formatDuration(now.difference(visit.checkInAt)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SummaryCard(
              title: 'Activity Summary',
              rows: [
                _SummaryRow(
                  label: 'Regular Orders',
                  value: summary.regularOrderCount.toString(),
                ),
                _SummaryRow(
                  label: 'Canvas Orders',
                  value: summary.canvasOrderCount.toString(),
                ),
                _SummaryRow(
                  label: 'Returns',
                  value: summary.returnOrderCount.toString(),
                ),
                _SummaryRow(
                  label: 'Promo Checks',
                  value: summary.promoCheckCount.toString(),
                ),
                _SummaryRow(
                  label: 'Competitor Activities',
                  value: summary.competitorActivityCount.toString(),
                ),
                _SummaryRow(
                  label: 'Planogram Checks',
                  value: summary.planogramCheckCount.toString(),
                ),
                _SummaryRow(
                  label: 'Stock Checks',
                  value: summary.stockCheckCount.toString(),
                ),
                _SummaryRow(
                  label: 'Store Photos',
                  value: summary.storePhotoCount.toString(),
                ),
                _SummaryRow(
                  label: 'Visit Notes',
                  value: summary.visitNoteCount.toString(),
                ),
                _SummaryRow(
                  label: 'Pending Sync',
                  value: summary.pendingSyncCount.toString(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _VisitNoteCard(note: summary.latestVisitNote),
          ],
        ),
      ),
    );
  }

  static Future<void> _confirmEndVisit(
    BuildContext context,
    bool hasAnyStoreActivity,
  ) async {
    if (!hasAnyStoreActivity) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('End visit?'),
          content: const Text(
            'No store activity recorded. Are you sure you want to end this visit?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('End Visit'),
            ),
          ],
        ),
      );

      if (confirmed != true || !context.mounted) {
        return;
      }
    }

    final visit = AppStateScope.of(context).endActiveVisit();
    if (visit == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to end visit.')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visit completed and queued for sync.')),
    );
    context.go(AppRoutes.visit);
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours <= 0) {
      return '$minutes min';
    }
    return '$hours hr $minutes min';
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFFBEB),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_outlined, color: AppTheme.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.rows});

  final String title;
  final List<_SummaryRow> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _VisitNoteCard extends StatelessWidget {
  const _VisitNoteCard({required this.note});

  final VisitNote? note;

  @override
  Widget build(BuildContext context) {
    final note = this.note;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visit Note Summary',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (note == null)
              const Text('No visit note saved yet.')
            else ...[
              _SummaryRow(label: 'Result', value: note.result.label),
              if (note.notes.isNotEmpty)
                _SummaryRow(label: 'Notes', value: note.notes),
              if (note.followUpDate != null)
                _SummaryRow(
                  label: 'Follow-up',
                  value: DateFormatters.compactDate(note.followUpDate!),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
