import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/repositories/app_state_scope.dart';

class PlanogramCheckDetailPage extends StatelessWidget {
  const PlanogramCheckDetailPage({required this.checkId, super.key});

  final String checkId;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final check = repository.getPlanogramCheckById(checkId);
    final customer = check == null
        ? null
        : repository.getCustomerById(check.customerId);

    if (check == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Planogram Detail')),
        body: const Center(child: Text('Planogram check was not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Planogram Detail')),
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
                    const SizedBox(height: 12),
                    StatusChip(
                      label: check.syncStatus.label,
                      color: AppTheme.warning,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Compliance',
                      value: check.complianceStatus.label,
                    ),
                    _InfoRow(label: 'Shelf Area', value: check.shelfArea.label),
                    _InfoRow(
                      label: 'Shelf Level',
                      value: check.shelfLevel.label,
                    ),
                    _InfoRow(
                      label: 'Total Facing',
                      value: check.facingCount.toString(),
                    ),
                    _InfoRow(
                      label: 'Missing SKUs',
                      value: check.missingSkus.isEmpty
                          ? '-'
                          : check.missingSkus.join(', '),
                    ),
                    _InfoRow(
                      label: 'Before Photo',
                      value: check.beforePhotoCaptured ? 'Captured' : 'Missing',
                    ),
                    _InfoRow(
                      label: 'After Photo',
                      value: check.afterPhotoCaptured ? 'Captured' : 'Missing',
                    ),
                    _InfoRow(
                      label: 'Shelf Share',
                      value: check.shareOfShelfEstimate.label,
                    ),
                    _InfoRow(label: 'Main Issue', value: check.mainIssue.label),
                    _InfoRow(
                      label: 'Recommended',
                      value: check.recommendedAction.label,
                    ),
                    _InfoRow(
                      label: 'Action Taken',
                      value: check.actionTaken.label,
                    ),
                    _InfoRow(
                      label: 'Notes',
                      value: check.notes.isEmpty ? '-' : check.notes,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _DetailSection(
              title: 'Own Product Rows',
              values: check.ownProductRows
                  .map(
                    (row) =>
                        '${row.productName} • Facing ${row.facingCount} • ${row.availability.label} • ${row.placementStatus.label}',
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            _DetailSection(
              title: 'Competitor Rows',
              values: check.competitorProductRows
                  .map(
                    (row) =>
                        '${row.brandName} ${row.productName} • Facing ${row.facingCount}',
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.values});

  final String title;
  final List<String> values;

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
            const SizedBox(height: 10),
            if (values.isEmpty)
              const Text('-')
            else
              ...values.map(
                (value) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ],
        ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
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
