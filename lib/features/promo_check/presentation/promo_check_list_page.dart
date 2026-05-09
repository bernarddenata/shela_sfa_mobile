import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/promo_check.dart';
import '../../../data/repositories/app_state_scope.dart';

class PromoCheckListPage extends StatelessWidget {
  const PromoCheckListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final checks = repository.getPromoChecks();

    return Scaffold(
      appBar: AppBar(title: const Text('Promo Check History')),
      body: SafeArea(
        child: checks.isEmpty
            ? const Center(child: Text('No promo checks yet.'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: checks.length,
                itemBuilder: (context, index) {
                  final check = checks[index];
                  final customer = repository.getCustomerById(check.customerId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PromoCheckCard(
                      check: check,
                      customerName: customer?.name ?? 'Customer',
                      onTap: () => context.push(
                        AppRoutes.promoCheckDetailPath(check.id),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _PromoCheckCard extends StatelessWidget {
  const _PromoCheckCard({
    required this.check,
    required this.customerName,
    required this.onTap,
  });

  final PromoCheck check;
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
                      check.promoName,
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
              Text(customerName),
              const SizedBox(height: 6),
              Text(check.complianceStatus.label),
              const SizedBox(height: 6),
              Text(DateFormatters.dateTime(check.createdAt)),
            ],
          ),
        ),
      ),
    );
  }
}
