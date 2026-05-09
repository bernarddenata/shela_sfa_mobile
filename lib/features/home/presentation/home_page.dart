import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/menu_tile.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/summary_card.dart';
import '../../../data/repositories/app_state_scope.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final user = repository.activeUser;
    final dashboard = repository.getHomeDashboard();
    final textTheme = Theme.of(context).textTheme;

    if (user == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: StatusChip(
                label: dashboard.isOnline ? 'Online' : 'Offline',
                color: dashboard.isOnline ? AppTheme.accent : AppTheme.warning,
                icon: dashboard.isOnline ? Icons.wifi : Icons.wifi_off,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning, ${user.firstName}',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.employeeName,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.companyName,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.store_mall_directory_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user.branchName,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DateFormatters.readableDate(DateTime.now()),
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoPill(
                    label: 'Last sync',
                    value: DateFormatters.shortTime(dashboard.lastSyncAt),
                    icon: Icons.sync,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoPill(
                    label: 'Pending sync',
                    value: dashboard.pendingSync.toString(),
                    icon: Icons.outbox_outlined,
                  ),
                ),
              ],
            ),
            if (dashboard.failedSync > 0) ...[
              const SizedBox(height: 10),
              _InfoPill(
                label: 'Failed sync',
                value: dashboard.failedSync.toString(),
                icon: Icons.error_outline,
              ),
            ],
            const SizedBox(height: 20),
            Text(
              "Today's Work",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.18,
              children: [
                SummaryCard(
                  title: "Today's Visit Plan",
                  value: dashboard.todayVisitPlan.toString(),
                  icon: Icons.route_outlined,
                  color: AppTheme.primary,
                ),
                SummaryCard(
                  title: 'Completed Visit',
                  value: dashboard.completedVisit.toString(),
                  icon: Icons.task_alt,
                  color: AppTheme.accent,
                ),
                SummaryCard(
                  title: 'Pending Visit',
                  value: dashboard.pendingVisit.toString(),
                  icon: Icons.pending_actions_outlined,
                  color: AppTheme.warning,
                ),
                SummaryCard(
                  title: 'Sales Today',
                  value: CurrencyFormatters.rupiah(dashboard.salesToday),
                  icon: Icons.receipt_long_outlined,
                  color: AppTheme.primary,
                ),
                SummaryCard(
                  title: 'Pending Sync',
                  value: dashboard.pendingSync.toString(),
                  icon: Icons.cloud_upload_outlined,
                  color: AppTheme.warning,
                ),
                SummaryCard(
                  title: 'Failed Sync',
                  value: dashboard.failedSync.toString(),
                  icon: Icons.error_outline,
                  color: AppTheme.danger,
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Home Menu',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            MenuTile(
              title: 'Visit',
              subtitle: "Open today's call plan",
              icon: Icons.storefront_outlined,
              color: AppTheme.accent,
              isProminent: true,
              onTap: () => context.push(AppRoutes.visit),
            ),
            const SizedBox(height: 10),
            MenuTile(
              title: 'Sales Order',
              subtitle: 'View submitted sales orders',
              icon: Icons.shopping_cart_outlined,
              color: AppTheme.primary,
              onTap: () => context.push(AppRoutes.salesOrders),
            ),
            const SizedBox(height: 10),
            MenuTile(
              title: 'Customer',
              subtitle: 'Browse branch customers',
              icon: Icons.groups_outlined,
              color: AppTheme.primary,
              onTap: () => _showPhaseMessage(context, 'Customer'),
            ),
            const SizedBox(height: 10),
            MenuTile(
              title: 'Sync Center',
              subtitle: 'Review offline activity queue',
              icon: Icons.sync_outlined,
              color: AppTheme.primary,
              onTap: () => context.push(AppRoutes.syncCenter),
            ),
            const SizedBox(height: 10),
            MenuTile(
              title: 'Profile',
              subtitle: 'View active salesman context',
              icon: Icons.badge_outlined,
              color: AppTheme.primary,
              onTap: () => _showPhaseMessage(context, 'Profile'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showPhaseMessage(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title will be completed in a later version.')),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
