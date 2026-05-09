import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/app_state_scope.dart';

const returnReasons = [
  'Expired',
  'Damaged',
  'Wrong Item',
  'Slow Moving',
  'Customer Request',
];

class ReturnOrderPage extends StatefulWidget {
  const ReturnOrderPage({super.key});

  @override
  State<ReturnOrderPage> createState() => _ReturnOrderPageState();
}

class _ReturnOrderPageState extends State<ReturnOrderPage> {
  final _notesController = TextEditingController();
  final Map<String, int> _quantities = {};
  String? _reason;
  bool _photoCaptured = false;

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

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Return Order')),
        body: const Center(
          child: Text('Please check in before creating return.'),
        ),
      );
    }

    final products = repository.getOwnSellableProducts();
    final totalQuantity = _quantities.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Return Order')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _submit,
            child: Text('Submit Return ($totalQuantity qty)'),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _CustomerCard(name: customer.name, address: customer.address),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _reason,
              decoration: const InputDecoration(labelText: 'Return Reason'),
              items: returnReasons
                  .map(
                    (reason) =>
                        DropdownMenuItem(value: reason, child: Text(reason)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _reason = value),
            ),
            const SizedBox(height: 12),
            _PhotoCaptureCard(
              photoCaptured: _photoCaptured,
              onCapture: () => setState(() => _photoCaptured = true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 14),
            Text(
              'Products',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...products.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ReturnProductCard(
                  product: product,
                  quantity: _quantities[product.id] ?? 0,
                  onChanged: (quantity) => _setQuantity(product.id, quantity),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setQuantity(String productId, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _quantities.remove(productId);
      } else {
        _quantities[productId] = quantity;
      }
    });
  }

  void _submit() {
    if (_quantities.isEmpty) {
      _showMessage('Add at least one returned product.');
      return;
    }
    if (_reason == null) {
      _showMessage('Return reason is required.');
      return;
    }
    if (!_photoCaptured) {
      _showMessage('Photo is required.');
      return;
    }

    final returnOrder = AppStateScope.of(context).submitReturnOrder(
      quantitiesByProductId: Map.unmodifiable(_quantities),
      reason: _reason!,
      photoCaptured: _photoCaptured,
      notes: _notesController.text.trim(),
    );
    if (returnOrder == null) {
      _showMessage('Unable to submit return.');
      return;
    }

    context.go(AppRoutes.returnSuccessPath(returnOrder.id));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ReturnProductCard extends StatelessWidget {
  const _ReturnProductCard({
    required this.product,
    required this.quantity,
    required this.onChanged,
  });

  final Product product;
  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
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
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatters.rupiah(product.price),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(product.sku),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: quantity == 0
                      ? null
                      : () => onChanged(quantity - 1),
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 58,
                  child: Text(
                    quantity.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: () => onChanged(quantity + 1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.name, required this.address});

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

class _PhotoCaptureCard extends StatelessWidget {
  const _PhotoCaptureCard({
    required this.photoCaptured,
    required this.onCapture,
  });

  final bool photoCaptured;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Return Photo',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              photoCaptured
                  ? 'Photo captured locally.'
                  : 'Photo is required before submit.',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onCapture,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(photoCaptured ? 'Retake Photo' : 'Capture Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
