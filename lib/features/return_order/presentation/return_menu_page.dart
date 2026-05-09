import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/menu_tile.dart';
import '../../../data/repositories/app_state_scope.dart';

class ReturnMenuPage extends StatelessWidget {
  const ReturnMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final visit = repository.activeVisit;
    final customer = visit == null
        ? null
        : repository.getCustomerById(visit.customerId);

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Return')),
        body: const Center(
          child: Text('Please check in before creating return.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Return')),
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
                      customer.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      customer.address,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            MenuTile(
              title: 'Return Order',
              subtitle: 'Record returned products',
              icon: Icons.assignment_return_outlined,
              color: AppTheme.accent,
              isProminent: true,
              onTap: () => context.push(AppRoutes.returnOrder),
            ),
            const SizedBox(height: 10),
            MenuTile(
              title: 'Return Swap Order',
              subtitle: 'Record return with replacement product',
              icon: Icons.swap_horiz_outlined,
              color: AppTheme.primary,
              onTap: () => context.push(AppRoutes.returnSwapOrder),
            ),
            const SizedBox(height: 10),
            MenuTile(
              title: 'Return History',
              subtitle: 'View local return activities',
              icon: Icons.history_outlined,
              color: AppTheme.primary,
              onTap: () => context.push(AppRoutes.returns),
            ),
          ],
        ),
      ),
    );
  }
}
