import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/repositories/app_state_scope.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final order = repository.getSalesOrderById(orderId);
    final customer = order == null
        ? null
        : repository.getCustomerById(order.customerId);

    if (order == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Success')),
        body: const Center(child: Text('Order was not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order Success')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle, color: AppTheme.accent, size: 72),
              const SizedBox(height: 18),
              Text(
                'Order Submitted',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        label: 'Order Number',
                        value: order.orderNumber,
                      ),
                      _DetailRow(
                        label: 'Order Type',
                        value: order.orderType.label,
                      ),
                      _DetailRow(label: 'Customer', value: customer.name),
                      _DetailRow(
                        label: 'Grand Total',
                        value: CurrencyFormatters.rupiah(order.grandTotal),
                      ),
                      const SizedBox(height: 8),
                      StatusChip(
                        label: order.syncStatus.label,
                        color: AppTheme.warning,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go(AppRoutes.store),
                child: const Text('Back to Store Page'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () =>
                    context.push(AppRoutes.salesOrderDetailPath(order.id)),
                child: const Text('View Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
