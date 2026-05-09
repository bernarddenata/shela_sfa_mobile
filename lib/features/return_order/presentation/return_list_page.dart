import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/return_order.dart';
import '../../../data/repositories/app_state_scope.dart';

class ReturnListPage extends StatelessWidget {
  const ReturnListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final returns = repository.getReturnOrders();

    return Scaffold(
      appBar: AppBar(title: const Text('Return History')),
      body: SafeArea(
        child: returns.isEmpty
            ? const Center(child: Text('No return activities yet.'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: returns.length,
                itemBuilder: (context, index) {
                  final returnOrder = returns[index];
                  final customer = repository.getCustomerById(
                    returnOrder.customerId,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReturnCard(
                      returnOrder: returnOrder,
                      customerName: customer?.name ?? 'Customer',
                      onTap: () => context.push(
                        AppRoutes.returnDetailPath(returnOrder.id),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _ReturnCard extends StatelessWidget {
  const _ReturnCard({
    required this.returnOrder,
    required this.customerName,
    required this.onTap,
  });

  final ReturnOrder returnOrder;
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
                      returnOrder.returnNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  StatusChip(
                    label: returnOrder.syncStatus.label,
                    color: AppTheme.warning,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(customerName),
              const SizedBox(height: 6),
              Text('${returnOrder.returnType.label} • ${returnOrder.reason}'),
              const SizedBox(height: 6),
              Text(DateFormatters.dateTime(returnOrder.createdAt)),
            ],
          ),
        ),
      ),
    );
  }
}
