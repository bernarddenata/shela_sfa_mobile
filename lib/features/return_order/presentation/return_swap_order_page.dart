import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/app_state_scope.dart';
import 'return_order_page.dart';

class ReturnSwapOrderPage extends StatefulWidget {
  const ReturnSwapOrderPage({super.key});

  @override
  State<ReturnSwapOrderPage> createState() => _ReturnSwapOrderPageState();
}

class _ReturnSwapOrderPageState extends State<ReturnSwapOrderPage> {
  final _notesController = TextEditingController();
  String? _returnedProductId;
  String? _replacementProductId;
  String? _reason;
  int _returnedQuantity = 0;
  int _replacementQuantity = 0;
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
    final products = repository.getOwnSellableProducts();

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Return Swap Order')),
        body: const Center(
          child: Text('Please check in before creating return.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Return Swap Order')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _submit,
            child: const Text('Submit Swap'),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ProductPickerSection(
              title: 'Returned Product',
              products: products,
              selectedProductId: _returnedProductId,
              quantity: _returnedQuantity,
              onProductChanged: (value) =>
                  setState(() => _returnedProductId = value),
              onQuantityChanged: (value) => setState(() {
                _returnedQuantity = value < 0 ? 0 : value;
              }),
            ),
            const SizedBox(height: 12),
            _ProductPickerSection(
              title: 'Replacement Product',
              products: products,
              selectedProductId: _replacementProductId,
              quantity: _replacementQuantity,
              onProductChanged: (value) =>
                  setState(() => _replacementProductId = value),
              onQuantityChanged: (value) => setState(() {
                _replacementQuantity = value < 0 ? 0 : value;
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _reason,
              decoration: const InputDecoration(labelText: 'Reason'),
              items: returnReasons
                  .map(
                    (reason) =>
                        DropdownMenuItem(value: reason, child: Text(reason)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _reason = value),
            ),
            const SizedBox(height: 12),
            _SwapPhotoCard(
              photoCaptured: _photoCaptured,
              onCapture: () => setState(() => _photoCaptured = true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_returnedProductId == null) {
      _showMessage('Returned product is required.');
      return;
    }
    if (_returnedQuantity <= 0) {
      _showMessage('Returned quantity must be greater than 0.');
      return;
    }
    if (_replacementProductId == null) {
      _showMessage('Replacement product is required.');
      return;
    }
    if (_replacementQuantity <= 0) {
      _showMessage('Replacement quantity must be greater than 0.');
      return;
    }
    if (_reason == null) {
      _showMessage('Reason is required.');
      return;
    }
    if (!_photoCaptured) {
      _showMessage('Photo is required.');
      return;
    }

    final returnOrder = AppStateScope.of(context).submitReturnSwapOrder(
      returnedProductId: _returnedProductId!,
      returnedQuantity: _returnedQuantity,
      replacementProductId: _replacementProductId!,
      replacementQuantity: _replacementQuantity,
      reason: _reason!,
      photoCaptured: _photoCaptured,
      notes: _notesController.text.trim(),
    );

    if (returnOrder == null) {
      _showMessage('Unable to submit return swap.');
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

class _ProductPickerSection extends StatelessWidget {
  const _ProductPickerSection({
    required this.title,
    required this.products,
    required this.selectedProductId,
    required this.quantity,
    required this.onProductChanged,
    required this.onQuantityChanged,
  });

  final String title;
  final List<Product> products;
  final String? selectedProductId;
  final int quantity;
  final ValueChanged<String?> onProductChanged;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedProductId,
              decoration: const InputDecoration(labelText: 'Select product'),
              items: products
                  .map(
                    (product) => DropdownMenuItem(
                      value: product.id,
                      child: Text(product.name),
                    ),
                  )
                  .toList(),
              onChanged: onProductChanged,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: quantity == 0
                      ? null
                      : () => onQuantityChanged(quantity - 1),
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
                  onPressed: () => onQuantityChanged(quantity + 1),
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

class _SwapPhotoCard extends StatelessWidget {
  const _SwapPhotoCard({required this.photoCaptured, required this.onCapture});

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
              photoCaptured ? 'Photo captured locally.' : 'Photo is required.',
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
