import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../data/models/product.dart';
import '../../../data/models/sales_order.dart';
import '../../../data/models/uom.dart';
import '../../../data/repositories/app_state_scope.dart';
import '../../../data/repositories/mock_sfa_repository.dart';

class OrderEntryPage extends StatefulWidget {
  const OrderEntryPage({required this.orderType, super.key});

  final SalesOrderType orderType;

  @override
  State<OrderEntryPage> createState() => _OrderEntryPageState();
}

class _OrderEntryPageState extends State<OrderEntryPage> {
  final _searchController = TextEditingController();
  final Map<String, int> _quantities = {};
  final Map<String, String> _selectedUomIds = {};
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

  String _uomIdFor(Product product) =>
      _selectedUomIds[product.id] ?? product.baseUomId;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final visit = repository.activeVisit;
    final customer = visit == null
        ? null
        : repository.getCustomerById(visit.customerId);

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.orderType.label)),
        body: const Center(
          child: Text('Please check in before creating order.'),
        ),
      );
    }

    final products = repository
        .getOwnSellableProducts()
        .where((product) {
          if (_query.isEmpty) return true;
          return product.name.toLowerCase().contains(_query) ||
              product.sku.toLowerCase().contains(_query);
        })
        .toList(growable: false);

    final selectedProducts = repository.getOwnSellableProducts().where(
      (product) => (_quantities[product.id] ?? 0) > 0,
    );
    final subtotal = selectedProducts.fold<int>(
      0,
      (total, product) =>
          total + product.price * (_quantities[product.id] ?? 0),
    );
    final totalQuantity = _quantities.values.fold<int>(
      0,
      (total, quantity) => total + quantity,
    );
    final itemCount = _quantities.values.where((q) => q > 0).length;
    final discount = repository.calculateDiscount(
      subtotal: subtotal,
      totalQuantity: totalQuantity,
    );
    final grandTotal = subtotal - discount;

    return Scaffold(
      appBar: AppBar(title: Text(widget.orderType.label)),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CartSummary(
                itemCount: itemCount,
                totalQuantity: totalQuantity,
                subtotal: subtotal,
                discount: discount,
                grandTotal: grandTotal,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: itemCount == 0 ? null : _submitOrder,
                child: const Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  child: _ProductOrderCard(
                    product: product,
                    orderType: widget.orderType,
                    availableUoms: repository.getUomsForProduct(product),
                    selectedUomId: _uomIdFor(product),
                    quantity: _quantities[product.id] ?? 0,
                    onUomChanged: (uomId) =>
                        setState(() => _selectedUomIds[product.id] = uomId),
                    onChanged: (quantity) => _setQuantity(product, quantity),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _setQuantity(Product product, int quantity) {
    final cappedQuantity = widget.orderType == SalesOrderType.canvas
        ? quantity.clamp(0, product.canvasStock)
        : quantity.clamp(0, 999);
    if (widget.orderType == SalesOrderType.canvas &&
        quantity > product.canvasStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity cannot exceed canvas stock.')),
      );
    }

    setState(() {
      if (cappedQuantity == 0) {
        _quantities.remove(product.id);
      } else {
        _quantities[product.id] = cappedQuantity;
      }
    });
  }

  void _submitOrder() {
    if (_quantities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one product to submit order.'),
        ),
      );
      return;
    }

    final repository = AppStateScope.of(context);
    final lineItems = _quantities.entries.map((entry) {
      final product = repository.getProductById(entry.key)!;
      final uomId = _uomIdFor(product);
      final uom = repository.getUomById(uomId);
      return OrderLineInput(
        productId: entry.key,
        uomId: uomId,
        uomCode: uom?.code ?? 'PCS',
        quantity: entry.value,
      );
    }).toList();

    final order = repository.submitSalesOrder(
      orderType: widget.orderType,
      lineItems: lineItems,
    );

    if (order == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to submit order.')));
      return;
    }

    context.go(AppRoutes.orderSuccessPath(order.id));
  }
}

class _ProductOrderCard extends StatelessWidget {
  const _ProductOrderCard({
    required this.product,
    required this.orderType,
    required this.availableUoms,
    required this.selectedUomId,
    required this.quantity,
    required this.onUomChanged,
    required this.onChanged,
  });

  final Product product;
  final SalesOrderType orderType;
  final List<Uom> availableUoms;
  final String selectedUomId;
  final int quantity;
  final ValueChanged<String> onUomChanged;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isCanvas = orderType == SalesOrderType.canvas;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.sku,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatters.rupiah(product.price),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            if (isCanvas) ...[
              const SizedBox(height: 8),
              Text(
                'Canvas stock: ${product.canvasStock}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: product.canvasStock > 0
                      ? AppTheme.accent
                      : AppTheme.danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            if (availableUoms.length > 1) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: selectedUomId,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: availableUoms
                    .map(
                      (uom) => DropdownMenuItem(
                        value: uom.id,
                        child: Text(uom.code),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onUomChanged(value);
                },
              ),
            ] else if (availableUoms.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Unit: ${availableUoms.first.code}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: quantity == 0
                      ? null
                      : () => onChanged(quantity - 1),
                  icon: const Icon(Icons.remove),
                ),
                Container(
                  width: 56,
                  alignment: Alignment.center,
                  child: Text(
                    quantity.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: isCanvas && quantity >= product.canvasStock
                      ? null
                      : () => onChanged(quantity + 1),
                  icon: const Icon(Icons.add),
                ),
                const Spacer(),
                TextButton(
                  onPressed: quantity == 0 ? () => onChanged(1) : null,
                  child: Text(quantity == 0 ? 'Add' : 'Added'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.itemCount,
    required this.totalQuantity,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
  });

  final int itemCount;
  final int totalQuantity;
  final int subtotal;
  final int discount;
  final int grandTotal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryRow(
          label: 'Items',
          value: '$itemCount item / $totalQuantity qty',
        ),
        _SummaryRow(
          label: 'Subtotal',
          value: CurrencyFormatters.rupiah(subtotal),
        ),
        _SummaryRow(
          label: 'Discount',
          value: CurrencyFormatters.rupiah(discount),
        ),
        const Divider(),
        _SummaryRow(
          label: 'Grand Total',
          value: CurrencyFormatters.rupiah(grandTotal),
          isStrong: true,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isStrong = false,
  });

  final String label;
  final String value;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    final style = isStrong
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)
        : Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
