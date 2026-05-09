import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/repositories/app_state_scope.dart';

class PromoCheckDetailPage extends StatelessWidget {
  const PromoCheckDetailPage({required this.promoCheckId, super.key});

  final String promoCheckId;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final check = repository.getPromoCheckById(promoCheckId);
    final customer = check == null
        ? null
        : repository.getCustomerById(check.customerId);

    if (check == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Promo Check Detail')),
        body: const Center(child: Text('Promo check was not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Promo Check Detail')),
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
                      check.promoName,
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
                    _InfoRow(label: 'Customer', value: customer.name),
                    _InfoRow(
                      label: 'Compliance',
                      value: check.complianceStatus.label,
                    ),
                    _InfoRow(
                      label: 'Photo',
                      value: check.photoCaptured ? 'Captured' : 'Missing',
                    ),
                    _InfoRow(
                      label: 'Notes',
                      value: check.notes.isEmpty ? '-' : check.notes,
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
