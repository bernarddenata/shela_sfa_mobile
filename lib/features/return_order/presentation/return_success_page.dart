import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/repositories/app_state_scope.dart';

class ReturnSuccessPage extends StatelessWidget {
  const ReturnSuccessPage({required this.returnOrderId, super.key});

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
        appBar: AppBar(title: const Text('Return Success')),
        body: const Center(child: Text('Return was not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Return Success')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle, color: AppTheme.accent, size: 72),
              const SizedBox(height: 18),
              Text(
                'Return Submitted',
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
                      _Row(
                        label: 'Return Number',
                        value: returnOrder.returnNumber,
                      ),
                      _Row(
                        label: 'Return Type',
                        value: returnOrder.returnType.label,
                      ),
                      _Row(label: 'Customer', value: customer.name),
                      _Row(label: 'Reason', value: returnOrder.reason),
                      const SizedBox(height: 8),
                      StatusChip(
                        label: returnOrder.syncStatus.label,
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
                    context.push(AppRoutes.returnDetailPath(returnOrder.id)),
                child: const Text('View Return'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
