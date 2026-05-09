import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/competitor_activity.dart';
import '../../../data/repositories/app_state_scope.dart';

class CompetitorActivityListPage extends StatelessWidget {
  const CompetitorActivityListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final activities = repository.getCompetitorActivities();

    return Scaffold(
      appBar: AppBar(title: const Text('Competitor Activity History')),
      body: SafeArea(
        child: activities.isEmpty
            ? const Center(child: Text('No competitor activities yet.'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  final customer = repository.getCustomerById(
                    activity.customerId,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ActivityCard(
                      activity: activity,
                      customerName: customer?.name ?? 'Customer',
                      onTap: () => context.push(
                        AppRoutes.competitorActivityDetailPath(activity.id),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.customerName,
    required this.onTap,
  });

  final CompetitorActivity activity;
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
                      activity.competitorBrand,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  StatusChip(
                    label: activity.syncStatus.label,
                    color: AppTheme.warning,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(activity.competitorProduct),
              const SizedBox(height: 6),
              Text('${activity.activityType.label} • $customerName'),
              const SizedBox(height: 6),
              Text(DateFormatters.dateTime(activity.createdAt)),
            ],
          ),
        ),
      ),
    );
  }
}
