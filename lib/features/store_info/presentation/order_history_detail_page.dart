import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/repositories/app_state_scope.dart';

class OrderHistoryDetailPage extends StatelessWidget {
  const OrderHistoryDetailPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final order = repository.getOrderHistoryById(orderId);
    final customer = order == null
        ? null
        : repository.getCustomerById(order.customerId);

    if (order == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order History Detail')),
        body: const Center(child: Text('Order history was not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order History Detail')),
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
                      order.orderNumber,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatusChip(
                      label: order.syncStatus.label,
                      color: order.syncStatus.label == 'SYNCED'
                          ? AppTheme.accent
                          : AppTheme.warning,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Order Type', value: order.orderType.label),
                    _InfoRow(label: 'Customer', value: customer.name),
                    _InfoRow(
                      label: 'Order Time',
                      value: DateFormatters.dateTime(order.createdAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Product Items',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...order.items.map(
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
                      _InfoRow(
                        label: 'Price',
                        value: CurrencyFormatters.rupiah(item.price),
                      ),
                      _InfoRow(
                        label: 'Subtotal',
                        value: CurrencyFormatters.rupiah(item.subtotal),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Subtotal',
                      value: CurrencyFormatters.rupiah(order.subtotal),
                    ),
                    _InfoRow(
                      label: 'Discount',
                      value: CurrencyFormatters.rupiah(order.discount),
                    ),
                    const Divider(),
                    _InfoRow(
                      label: 'Grand Total',
                      value: CurrencyFormatters.rupiah(order.grandTotal),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Repeat Order will be implemented later.'),
                ),
              ),
              icon: const Icon(Icons.repeat),
              label: const Text('Repeat Order'),
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
