import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/planogram_check.dart';
import '../../../data/repositories/app_state_scope.dart';

class PlanogramCheckListPage extends StatelessWidget {
  const PlanogramCheckListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final checks = repository.getPlanogramChecks();

    return Scaffold(
      appBar: AppBar(title: const Text('Planogram History')),
      body: SafeArea(
        child: checks.isEmpty
            ? const Center(child: Text('No planogram checks yet.'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: checks.length,
                itemBuilder: (context, index) {
                  final check = checks[index];
                  final customer = repository.getCustomerById(check.customerId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PlanogramCard(
                      check: check,
                      customerName: customer?.name ?? 'Customer',
                      onTap: () => context.push(
                        AppRoutes.planogramCheckDetailPath(check.id),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _PlanogramCard extends StatelessWidget {
  const _PlanogramCard({
    required this.check,
    required this.customerName,
    required this.onTap,
  });

  final PlanogramCheck check;
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
                      customerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  StatusChip(
                    label: check.syncStatus.label,
                    color: AppTheme.warning,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(check.complianceStatus.label),
              const SizedBox(height: 6),
              Text(
                'Facing ${check.facingCount} • Missing ${check.missingSkus.length}',
              ),
              const SizedBox(height: 6),
              Text(DateFormatters.dateTime(check.createdAt)),
            ],
          ),
        ),
      ),
    );
  }
}
