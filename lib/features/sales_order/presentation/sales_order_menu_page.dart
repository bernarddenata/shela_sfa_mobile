import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/menu_tile.dart';
import '../../../data/repositories/app_state_scope.dart';

class SalesOrderMenuPage extends StatelessWidget {
  const SalesOrderMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final visit = repository.activeVisit;
    final customer = visit == null
        ? null
        : repository.getCustomerById(visit.customerId);

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sales / Order')),
        body: const Center(
          child: Text('Please check in before creating order.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sales / Order')),
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
              title: 'Regular Order',
              subtitle: 'Create standard customer order',
              icon: Icons.receipt_long_outlined,
              color: AppTheme.accent,
              isProminent: true,
              onTap: () => context.push(AppRoutes.regularOrder),
            ),
            const SizedBox(height: 10),
            MenuTile(
              title: 'Canvas Order',
              subtitle: 'Sell from salesman canvas stock',
              icon: Icons.inventory_outlined,
              color: AppTheme.primary,
              onTap: () => context.push(AppRoutes.canvasOrder),
            ),
            const SizedBox(height: 10),
            MenuTile(
              title: 'Draft Order',
              subtitle: 'Draft order list will be completed in a later version',
              icon: Icons.drafts_outlined,
              color: AppTheme.primary,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Draft Order will be completed in a later version.',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
