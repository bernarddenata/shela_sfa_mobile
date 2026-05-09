import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/call_plan.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/app_state_scope.dart';
import '../../../data/repositories/mock_sfa_repository.dart';

class VisitPage extends StatelessWidget {
  const VisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final callPlans = repository.getTodayCallPlans();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Visit')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormatters.readableDate(DateTime.now()),
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4B5563),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${callPlans.length} call plan${callPlans.length == 1 ? '' : 's'}',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.addCallPlan),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Call Plan'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (callPlans.isEmpty)
              const _EmptyCallPlanState()
            else
              ...callPlans.map((callPlan) {
                final customer = repository.getCustomerById(
                  callPlan.customerId,
                );
                if (customer == null) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CallPlanCard(callPlan: callPlan, customer: customer),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _EmptyCallPlanState extends StatelessWidget {
  const _EmptyCallPlanState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.route_outlined,
              color: AppTheme.accent,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No visit plan for today',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a customer to start your visit plan.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.addCallPlan),
            icon: const Icon(Icons.add),
            label: const Text('Add Call Plan'),
          ),
        ],
      ),
    );
  }
}

class _CallPlanCard extends StatelessWidget {
  const _CallPlanCard({required this.callPlan, required this.customer});

  final CallPlan callPlan;
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final statusColor = switch (callPlan.status) {
      CallPlanStatus.notStarted => AppTheme.warning,
      CallPlanStatus.inProgress => AppTheme.primary,
      CallPlanStatus.completed => AppTheme.accent,
      CallPlanStatus.missed => AppTheme.danger,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    callPlan.plannedSequence.toString(),
                    style: textTheme.titleMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        customer.address,
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                StatusChip(label: callPlan.status.label, color: statusColor),
                const Spacer(),
                SizedBox(
                  height: 42,
                  child: FilledButton(
                    onPressed: callPlan.status == CallPlanStatus.completed
                        ? null
                        : () => _startVisit(context, repository),
                    child: const Text('Start Visit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startVisit(BuildContext context, MockSfaRepository repository) {
    if (callPlan.status == CallPlanStatus.inProgress &&
        repository.getVisitByCallPlanId(callPlan.id) != null) {
      context.go(AppRoutes.store);
      return;
    }

    context.push(AppRoutes.checkInPath(callPlan.id));
  }
}
