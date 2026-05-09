import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/repositories/app_state_scope.dart';

class CompetitorActivityDetailPage extends StatelessWidget {
  const CompetitorActivityDetailPage({required this.activityId, super.key});

  final String activityId;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final activity = repository.getCompetitorActivityById(activityId);
    final customer = activity == null
        ? null
        : repository.getCustomerById(activity.customerId);

    if (activity == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Competitor Activity Detail')),
        body: const Center(child: Text('Competitor activity was not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Competitor Activity Detail')),
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
                      activity.competitorBrand,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StatusChip(
                      label: activity.syncStatus.label,
                      color: AppTheme.warning,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Customer', value: customer.name),
                    _InfoRow(
                      label: 'Product',
                      value: activity.competitorProduct,
                    ),
                    _InfoRow(
                      label: 'Activity Type',
                      value: activity.activityType.label,
                    ),
                    _InfoRow(
                      label: 'Price',
                      value: activity.price == null
                          ? '-'
                          : CurrencyFormatters.rupiah(activity.price!),
                    ),
                    _InfoRow(
                      label: 'Promo',
                      value: activity.promoDescription.isEmpty
                          ? '-'
                          : activity.promoDescription,
                    ),
                    _InfoRow(
                      label: 'Photo',
                      value: activity.photoCaptured ? 'Captured' : 'Missing',
                    ),
                    _InfoRow(
                      label: 'Notes',
                      value: activity.notes.isEmpty ? '-' : activity.notes,
                    ),
                  ],
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
