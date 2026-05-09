import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/sales_order.dart';
import '../../../data/repositories/app_state_scope.dart';

class SalesOrderListPage extends StatelessWidget {
  const SalesOrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final orders = repository.getSalesOrders();

    return Scaffold(
      appBar: AppBar(title: const Text('Sales Order')),
      body: SafeArea(
        child: orders.isEmpty
            ? const Center(child: Text('No sales orders yet.'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final customer = repository.getCustomerById(order.customerId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OrderCard(
                      order: order,
                      customerName: customer?.name ?? 'Customer',
                      onTap: () => context.push(
                        AppRoutes.salesOrderDetailPath(order.id),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.customerName,
    required this.onTap,
  });

  final SalesOrder order;
  final String customerName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  StatusChip(
                    label: order.syncStatus.label,
                    color: AppTheme.warning,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(customerName),
              const SizedBox(height: 6),
              Text(
                '${order.orderType.label} • ${DateFormatters.dateTime(order.createdAt)}',
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatters.rupiah(order.grandTotal),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
