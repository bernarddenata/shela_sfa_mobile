import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/app_state_scope.dart';

class ProductPriceListPage extends StatefulWidget {
  const ProductPriceListPage({super.key});

  @override
  State<ProductPriceListPage> createState() => _ProductPriceListPageState();
}

class _ProductPriceListPageState extends State<ProductPriceListPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final visit = repository.activeVisit;
    final customer = visit == null
        ? null
        : repository.getCustomerById(visit.customerId);

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product & Price List')),
        body: const Center(
          child: Text('Please check in before opening store information.'),
        ),
      );
    }

    final products = repository
        .getProducts()
        .where((product) => product.productType == ProductType.ownProduct)
        .where((product) {
          if (_query.isEmpty) {
            return true;
          }
          return product.name.toLowerCase().contains(_query) ||
              product.sku.toLowerCase().contains(_query);
        })
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Product & Price List')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _CustomerContext(name: customer.name, address: customer.address),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search product',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            if (products.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No product found.'),
                ),
              )
            else
              ...products.map(
                (product) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ProductCard(product: product),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  bool get _isNabati => product.name.toLowerCase().contains('nabati');

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push(AppRoutes.productDetailPath(product.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    CurrencyFormatters.rupiah(product.price),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(product.sku),
              const SizedBox(height: 8),
              Text('Canvas stock: ${product.canvasStock}'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_isNabati)
                    const StatusChip(
                      label: 'Promo Eligible',
                      color: AppTheme.accent,
                    ),
                  if (_isNabati)
                    const StatusChip(
                      label: 'Buy 10 Get 5%',
                      color: AppTheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Add to Order will be connected to order flow later.',
                    ),
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Add to Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerContext extends StatelessWidget {
  const _CustomerContext({required this.name, required this.address});

  final String name;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(address),
          ],
        ),
      ),
    );
  }
}
