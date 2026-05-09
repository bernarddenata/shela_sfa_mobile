import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/models/product.dart';
import '../../../data/models/stock_check.dart';
import '../../../data/models/uom.dart';
import '../../../data/repositories/app_state_scope.dart';

class StockCheckPage extends StatefulWidget {
  const StockCheckPage({super.key});

  @override
  State<StockCheckPage> createState() => _StockCheckPageState();
}

class _StockCheckPageState extends State<StockCheckPage> {
  final _notesController = TextEditingController();
  final List<_StockRowState> _rows = [_StockRowState()];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final visit = repository.activeVisit;
    final customer = visit == null
        ? null
        : repository.getCustomerById(visit.customerId);
    final products = repository.getOwnSellableProducts();

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stock Check')),
        body: const Center(
          child: Text('Please check in before recording store activity.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Check')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _submit,
            child: const Text('Submit Stock Check'),
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
                    Text(customer.address),
                    const SizedBox(height: 8),
                    Text(
                      'Visit status: ${visit.status.label}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ..._rows.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StockRowCard(
                  index: entry.key,
                  row: entry.value,
                  products: products,
                  availableUomsFor: (product) =>
                      repository.getUomsForProduct(product),
                  canRemove: _rows.length > 1,
                  onChanged: () => setState(() {}),
                  onRemove: () => setState(() => _rows.removeAt(entry.key)),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _rows.add(_StockRowState())),
              icon: const Icon(Icons.add),
              label: const Text('Add Product Row'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.stockChecks),
              icon: const Icon(Icons.history_outlined),
              label: const Text('View Stock Check History'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_rows.isEmpty) {
      _showMessage('Please add at least one product.');
      return;
    }

    final repository = AppStateScope.of(context);
    final items = <StockCheckItem>[];
    for (final row in _rows) {
      if (row.productId == null) {
        _showMessage('Please select product.');
        return;
      }
      if (row.quantityText.trim().isEmpty) {
        _showMessage('Please enter store stock quantity.');
        return;
      }
      final quantity = int.tryParse(row.quantityText.trim());
      if (quantity == null || quantity < 0) {
        _showMessage(
          'Store stock quantity must be greater than or equal to 0.',
        );
        return;
      }
      if (row.status == null) {
        _showMessage('Please select stock status.');
        return;
      }
      final product = repository.getProductById(row.productId!);
      if (product == null) {
        _showMessage('Please select product.');
        return;
      }
      final uomId = row.uomId ?? product.baseUomId;
      final uom = repository.getUomById(uomId);
      items.add(
        StockCheckItem(
          productId: product.id,
          productName: product.name,
          sku: product.sku,
          uomId: uomId,
          uomCode: uom?.code ?? 'PCS',
          quantity: quantity,
          status: row.status!,
        ),
      );
    }

    final check = repository.submitStockCheck(
      items: items,
      notes: _notesController.text,
    );
    if (check == null) {
      _showMessage('Unable to submit stock check.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stock Check submitted and queued.')),
    );
    context.go(AppRoutes.store);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StockRowState {
  String? productId;
  String? uomId;
  String quantityText = '';
  StockStatus? status;
}

class _StockRowCard extends StatelessWidget {
  const _StockRowCard({
    required this.index,
    required this.row,
    required this.products,
    required this.availableUomsFor,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final _StockRowState row;
  final List<Product> products;
  final List<Uom> Function(Product product) availableUomsFor;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final selectedProduct = row.productId == null
        ? null
        : products.where((p) => p.id == row.productId).firstOrNull;
    final availableUoms =
        selectedProduct == null ? <Uom>[] : availableUomsFor(selectedProduct);
    final effectiveUomId = row.uomId ?? selectedProduct?.baseUomId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Product Row ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: row.productId,
              decoration: const InputDecoration(labelText: 'Product'),
              items: products
                  .map(
                    (product) => DropdownMenuItem(
                      value: product.id,
                      child: Text(product.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                row.productId = value;
                row.uomId = null;
                onChanged();
              },
            ),
            if (availableUoms.length > 1) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: effectiveUomId,
                decoration: const InputDecoration(labelText: 'Unit'),
                items: availableUoms
                    .map(
                      (uom) => DropdownMenuItem(
                        value: uom.id,
                        child: Text(uom.code),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  row.uomId = value;
                  onChanged();
                },
              ),
            ] else if (availableUoms.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Unit: ${availableUoms.first.code}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Store Stock Quantity',
              ),
              onChanged: (value) {
                row.quantityText = value;
                onChanged();
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<StockStatus>(
              initialValue: row.status,
              decoration: const InputDecoration(labelText: 'Stock Status'),
              items: StockStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                row.status = value;
                onChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}
