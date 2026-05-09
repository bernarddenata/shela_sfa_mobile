import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/models/brand.dart';
import '../../../data/models/competitor_activity.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/app_state_scope.dart';

class CompetitorActivityPage extends StatefulWidget {
  const CompetitorActivityPage({super.key});

  @override
  State<CompetitorActivityPage> createState() => _CompetitorActivityPageState();
}

class _CompetitorActivityPageState extends State<CompetitorActivityPage> {
  final _priceController = TextEditingController();
  final _promoDescriptionController = TextEditingController();
  final _notesController = TextEditingController();
  Brand? _selectedBrand;
  Product? _selectedProduct;
  CompetitorActivityType? _activityType;
  bool _photoCaptured = false;

  @override
  void dispose() {
    _priceController.dispose();
    _promoDescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _selectedBrand != null &&
      _selectedProduct != null &&
      _activityType != null &&
      _photoCaptured;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final visit = repository.activeVisit;
    final customer = visit == null
        ? null
        : repository.getCustomerById(visit.customerId);
    final brands = repository.getCompetitorBrands();
    final products = repository.getCompetitorProducts(
      brandId: _selectedBrand?.id,
    );

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Competitor Activity')),
        body: const Center(
          child: Text('Please check in before recording store activity.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Competitor Activity')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _canSubmit ? _submit : null,
            child: const Text('Submit Competitor Activity'),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _ContextCard(
              customerName: customer.name,
              customerAddress: customer.address,
              visitStatus: visit.status.label,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Brand>(
              initialValue: _selectedBrand,
              decoration: const InputDecoration(
                labelText: 'Competitor Brand',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              items: brands
                  .map(
                    (brand) =>
                        DropdownMenuItem(value: brand, child: Text(brand.name)),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedBrand = value;
                _selectedProduct = null;
              }),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addCompetitorBrand,
                icon: const Icon(Icons.add),
                label: const Text('+ Add New Competitor Brand'),
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<Product>(
              initialValue: _selectedProduct,
              decoration: const InputDecoration(
                labelText: 'Competitor Product',
                prefixIcon: Icon(Icons.cookie_outlined),
              ),
              items: products
                  .map(
                    (product) => DropdownMenuItem(
                      value: product,
                      child: Text('${product.name} • ${product.sku}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedProduct = value),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addCompetitorProduct,
                icon: const Icon(Icons.add),
                label: const Text('+ Add New Competitor Product'),
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<CompetitorActivityType>(
              initialValue: _activityType,
              decoration: const InputDecoration(labelText: 'Activity Type'),
              items: CompetitorActivityType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _activityType = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (optional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _promoDescriptionController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Promo Description'),
            ),
            const SizedBox(height: 12),
            _CompetitorPhotoCard(
              photoCaptured: _photoCaptured,
              onCapture: () => setState(() => _photoCaptured = true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.competitorActivities),
              icon: const Icon(Icons.history_outlined),
              label: const Text('View Competitor Activity History'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCompetitorBrand() async {
    final name = await _TextInputDialog.show(
      context: context,
      title: 'Add New Competitor Brand',
      label: 'Brand Name',
    );
    if (name == null) {
      return;
    }
    if (!mounted) {
      return;
    }

    final brand = AppStateScope.of(context).addCompetitorBrand(name);
    if (brand == null) {
      _showMessage('Competitor brand already exists.');
      return;
    }
    setState(() {
      _selectedBrand = brand;
      _selectedProduct = null;
    });
  }

  Future<void> _addCompetitorProduct() async {
    final brand = _selectedBrand;
    if (brand == null) {
      _showMessage('Please select competitor brand first.');
      return;
    }

    final productData = await _CompetitorProductDialog.show(
      context: context,
      brandName: brand.name,
    );
    if (productData == null) {
      return;
    }
    if (!mounted) {
      return;
    }

    final product = AppStateScope.of(context).addCompetitorProduct(
      brandId: brand.id,
      name: productData.name,
      sku: productData.sku,
      category: productData.category,
      price: productData.price,
    );
    if (product == null) {
      _showMessage('Competitor product already exists or is invalid.');
      return;
    }
    setState(() => _selectedProduct = product);
  }

  void _submit() {
    if (_selectedBrand == null) {
      _showMessage('Please enter competitor brand.');
      return;
    }
    if (_selectedProduct == null) {
      _showMessage('Please enter competitor product.');
      return;
    }
    if (_activityType == null) {
      _showMessage('Please select activity type.');
      return;
    }
    if (!_photoCaptured) {
      _showMessage('Please capture competitor photo.');
      return;
    }

    int? price;
    final priceText = _priceController.text.trim();
    if (priceText.isNotEmpty) {
      price = int.tryParse(priceText);
      if (price == null || price < 0) {
        _showMessage('Price must be greater than or equal to 0.');
        return;
      }
    }

    final activity = AppStateScope.of(context).submitCompetitorActivity(
      competitorBrandId: _selectedBrand!.id,
      competitorProductId: _selectedProduct!.id,
      activityType: _activityType!,
      photoCaptured: _photoCaptured,
      price: price,
      promoDescription: _promoDescriptionController.text,
      notes: _notesController.text,
    );
    if (activity == null) {
      _showMessage('Unable to submit competitor activity.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Competitor Activity submitted and queued.'),
      ),
    );
    context.go(AppRoutes.store);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CompetitorProductInput {
  const _CompetitorProductInput({
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
  });

  final String name;
  final String sku;
  final String category;
  final int price;
}

class _CompetitorProductDialog extends StatefulWidget {
  const _CompetitorProductDialog({required this.brandName});

  final String brandName;

  static Future<_CompetitorProductInput?> show({
    required BuildContext context,
    required String brandName,
  }) {
    return showDialog<_CompetitorProductInput>(
      context: context,
      builder: (_) => _CompetitorProductDialog(brandName: brandName),
    );
  }

  @override
  State<_CompetitorProductDialog> createState() =>
      _CompetitorProductDialogState();
}

class _CompetitorProductDialogState extends State<_CompetitorProductDialog> {
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Competitor');
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.brandName} Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _skuController,
              decoration: const InputDecoration(labelText: 'SKU'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final sku = _skuController.text.trim();
            if (name.isEmpty || sku.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              _CompetitorProductInput(
                name: name,
                sku: sku,
                category: _categoryController.text.trim(),
                price: int.tryParse(_priceController.text.trim()) ?? 0,
              ),
            );
          },
          child: const Text('Add Product'),
        ),
      ],
    );
  }
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({required this.title, required this.label});

  final String title;
  final String label;

  static Future<String?> show({
    required BuildContext context,
    required String title,
    required String label,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => _TextInputDialog(title: title, label: label),
    );
  }

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: widget.label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final value = _controller.text.trim();
            if (value.isEmpty) {
              return;
            }
            Navigator.of(context).pop(value);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.customerName,
    required this.customerAddress,
    required this.visitStatus,
  });

  final String customerName;
  final String customerAddress;
  final String visitStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customerName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(customerAddress),
            const SizedBox(height: 8),
            Text(
              'Visit status: $visitStatus',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompetitorPhotoCard extends StatelessWidget {
  const _CompetitorPhotoCard({
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
              'Competitor Photo',
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
              label: Text(
                photoCaptured
                    ? 'Retake Competitor Photo'
                    : 'Take Competitor Photo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
