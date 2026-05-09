import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/return_order.dart';
import '../../../data/repositories/app_state_scope.dart';

class ReturnDetailPage extends StatelessWidget {
  const ReturnDetailPage({required this.returnOrderId, super.key});

  final String returnOrderId;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final returnOrder = repository.getReturnOrderById(returnOrderId);
    final customer = returnOrder == null
        ? null
        : repository.getCustomerById(returnOrder.customerId);

    if (returnOrder == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Return Detail')),
        body: const Center(child: Text('Return was not found.')),
      );
    }

    final items = returnOrder.returnType == ReturnOrderType.returnOrder
        ? returnOrder.items
        : [
            if (returnOrder.returnedItem != null) returnOrder.returnedItem!,
            if (returnOrder.replacementItem != null)
              returnOrder.replacementItem!,
          ];

    return Scaffold(
      appBar: AppBar(title: const Text('Return Detail')),
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
                      returnOrder.returnNumber,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatusChip(
                      label: returnOrder.syncStatus.label,
                      color: AppTheme.warning,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Return Type',
                      value: returnOrder.returnType.label,
                    ),
                    _InfoRow(label: 'Customer', value: customer.name),
                    _InfoRow(
                      label: 'Visit Reference',
                      value: returnOrder.visitId,
                    ),
                    _InfoRow(label: 'Reason', value: returnOrder.reason),
                    _InfoRow(
                      label: 'Created',
                      value: DateFormatters.dateTime(returnOrder.createdAt),
                    ),
                    _InfoRow(
                      label: 'Photo',
                      value: returnOrder.photoCaptured ? 'Captured' : 'Missing',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Products',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...items.map(
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
                      _InfoRow(
                        label: 'Quantity',
                        value: item.quantity.toString(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (returnOrder.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _InfoRow(label: 'Notes', value: returnOrder.notes),
                ),
              ),
            ],
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
