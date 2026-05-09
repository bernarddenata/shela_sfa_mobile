import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/repositories/app_state_scope.dart';

class StockCheckDetailPage extends StatelessWidget {
  const StockCheckDetailPage({required this.checkId, super.key});

  final String checkId;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final check = repository.getStockCheckById(checkId);
    final customer = check == null
        ? null
        : repository.getCustomerById(check.customerId);

    if (check == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stock Check Detail')),
        body: const Center(child: Text('Stock check was not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Check Detail')),
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
                    Text(
                      check.notes.isEmpty
                          ? 'Notes: -'
                          : 'Notes: ${check.notes}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Product Rows',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...check.items.map(
              (item) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(item.sku),
                      const SizedBox(height: 8),
                      Text('Quantity: ${item.quantity}'),
                      Text('Stock Status: ${item.status.label}'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
