import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/menu_tile.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/visit.dart';
import '../../../data/repositories/app_state_scope.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final visit = repository.activeVisit;
    final customer = visit == null
        ? null
        : repository.getCustomerById(visit.customerId);

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Store Page')),
        body: const Center(
          child: Text('Please check in before opening Store Page.'),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutes.visit);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Store Visit'),
          leading: IconButton(
            tooltip: 'Back to Visit Plan',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.visit),
          ),
          actions: [
            IconButton(
              tooltip: 'Go to Home',
              icon: const Icon(Icons.home_outlined),
              onPressed: () => context.go(AppRoutes.home),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _StoreHeader(
                visit: visit,
                customerName: customer.name,
                customerAddress: customer.address,
                pendingSyncCount: repository.getPendingSyncCountForVisit(
                  visit.id,
                ),
              ),
              const SizedBox(height: 18),
              _MenuSection(
                title: 'Primary Sales',
                children: [
                  MenuTile(
                    title: 'Sales / Order',
                    subtitle: 'Create store order',
                    icon: Icons.shopping_cart_outlined,
                    color: AppTheme.accent,
                    isProminent: true,
                    onTap: () => context.push(AppRoutes.salesOrderMenu),
                  ),
                  MenuTile(
                    title: 'Return',
                    subtitle: 'Record product returns',
                    icon: Icons.assignment_return_outlined,
                    color: AppTheme.primary,
                    onTap: () => context.push(AppRoutes.returnMenu),
                  ),
                ],
              ),
              _MenuSection(
                title: 'Retail Execution',
                children: [
                  MenuTile(
                    title: 'Promo Check',
                    subtitle: 'Check promo execution',
                    icon: Icons.local_offer_outlined,
                    color: AppTheme.primary,
                    onTap: () => context.push(AppRoutes.promoCheck),
                  ),
                  MenuTile(
                    title: 'Competitor Activity',
                    subtitle: 'Record competitor activity',
                    icon: Icons.compare_arrows_outlined,
                    color: AppTheme.primary,
                    onTap: () => context.push(AppRoutes.competitorActivity),
                  ),
                  MenuTile(
                    title: 'Planogram / Shelf Check',
                    subtitle: 'Review shelf compliance',
                    icon: Icons.view_column_outlined,
                    color: AppTheme.primary,
                    onTap: () => context.push(AppRoutes.planogramCheck),
                  ),
                  MenuTile(
                    title: 'Stock Check',
                    subtitle: 'Record store stock',
                    icon: Icons.inventory_2_outlined,
                    color: AppTheme.primary,
                    onTap: () => context.push(AppRoutes.stockCheck),
                  ),
                ],
              ),
              _MenuSection(
                title: 'Store Information',
                children: [
                  MenuTile(
                    title: 'Product & Price List',
                    subtitle: 'Browse local catalog',
                    icon: Icons.price_check_outlined,
                    color: AppTheme.primary,
                    onTap: () => context.push(AppRoutes.productPriceList),
                  ),
                  MenuTile(
                    title: 'Order History',
                    subtitle: 'Review customer orders',
                    icon: Icons.history_outlined,
                    color: AppTheme.primary,
                    onTap: () => context.push(AppRoutes.orderHistory),
                  ),
                  MenuTile(
                    title: 'Customer Info',
                    subtitle: 'View customer details',
                    icon: Icons.store_outlined,
                    color: AppTheme.primary,
                    onTap: () => context.push(AppRoutes.customerInfo),
                  ),
                ],
              ),
              _MenuSection(
                title: 'Visit Completion',
                children: [
                  MenuTile(
                    title: 'Visit Notes',
                    subtitle: 'Write visit result notes',
                    icon: Icons.note_alt_outlined,
                    color: AppTheme.primary,
                    onTap: () => context.push(AppRoutes.visitNotes),
                  ),
                  MenuTile(
                    title: 'Store Photo',
                    subtitle: 'Capture visit photos',
                    icon: Icons.photo_camera_outlined,
                    color: AppTheme.primary,
                    onTap: () => context.push(AppRoutes.storePhoto),
                  ),
                  MenuTile(
                    title: 'End Visit',
                    subtitle: 'Complete active visit',
                    icon: Icons.logout_outlined,
                    color: AppTheme.danger,
                    onTap: () => context.push(AppRoutes.endVisit),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({
    required this.visit,
    required this.customerName,
    required this.customerAddress,
    required this.pendingSyncCount,
  });

  final Visit visit;
  final String customerName;
  final String customerAddress;
  final int pendingSyncCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customerName,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              customerAddress,
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(label: visit.status.label, color: AppTheme.primary),
                const StatusChip(label: 'GPS Valid', color: AppTheme.accent),
                const StatusChip(
                  label: 'Fake GPS Not Detected',
                  color: AppTheme.accent,
                ),
                const StatusChip(
                  label: 'Selfie/Photo Captured',
                  color: AppTheme.accent,
                ),
                StatusChip(
                  label: '$pendingSyncCount Pending Sync',
                  color: pendingSyncCount > 0
                      ? AppTheme.warning
                      : AppTheme.accent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Checked in ${DateFormatters.dateTime(visit.checkInAt)}',
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4B5563),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...children.expand((child) => [child, const SizedBox(height: 10)]),
        ],
      ),
    );
  }
}
