import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/brand.dart';
import '../../../data/models/planogram_check.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/app_state_scope.dart';

class PlanogramCheckPage extends StatefulWidget {
  const PlanogramCheckPage({super.key});

  @override
  State<PlanogramCheckPage> createState() => _PlanogramCheckPageState();
}

class _PlanogramCheckPageState extends State<PlanogramCheckPage> {
  final _notesController = TextEditingController();
  final List<_OwnProductDraft> _ownRows = [_OwnProductDraft()];
  final List<_CompetitorProductDraft> _competitorRows = [];
  bool _beforePhotoCaptured = false;
  bool _afterPhotoCaptured = false;
  ShelfArea? _shelfArea;
  PlanogramMainIssue? _mainIssue;
  MerchandiserActionTaken? _actionTaken;
  PlanogramComplianceStatus? _complianceStatus;

  @override
  void dispose() {
    _notesController.dispose();
    for (final row in _ownRows) {
      row.dispose();
    }
    for (final row in _competitorRows) {
      row.dispose();
    }
    super.dispose();
  }

  bool get _requiresAfterPhoto =>
      _actionTaken != null &&
      _actionTaken != MerchandiserActionTaken.noActionTaken;

  bool get _notesRequiredForNoAction =>
      _actionTaken == MerchandiserActionTaken.noActionTaken &&
      _mainIssue != null &&
      _mainIssue != PlanogramMainIssue.noIssue;

  bool get _canSubmit =>
      _beforePhotoCaptured &&
      _shelfArea != null &&
      _ownRows.isNotEmpty &&
      _ownRows.every((row) => row.isComplete) &&
      _mainIssue != null &&
      _actionTaken != null &&
      _complianceStatus != null &&
      (!_requiresAfterPhoto || _afterPhotoCaptured) &&
      (!_notesRequiredForNoAction || _notesController.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final visit = repository.activeVisit;
    final customer = visit == null
        ? null
        : repository.getCustomerById(visit.customerId);
    final ownProducts = repository.getOwnSellableProducts();
    final competitorBrands = repository.getCompetitorBrands();

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Planogram / Shelf Check')),
        body: const Center(
          child: Text('Please check in before recording store activity.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Planogram / Shelf Check')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _canSubmit ? _submit : null,
            child: const Text('Submit Planogram Check'),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _SectionCard(
              title: '1. Customer Context',
              child: _ContextContent(
                customerName: customer.name,
                customerAddress: customer.address,
                visitStatus: visit.status.label,
              ),
            ),
            _SectionCard(
              title: '2. Before Photo',
              child: _PhotoCapture(
                label: 'Before shelf photo',
                captured: _beforePhotoCaptured,
                onCapture: () => setState(() => _beforePhotoCaptured = true),
              ),
            ),
            _SectionCard(
              title: '3. Shelf Location',
              child: _EnumDropdown<ShelfArea>(
                label: 'Shelf Area',
                value: _shelfArea,
                values: ShelfArea.values,
                labelOf: (value) => value.label,
                onChanged: (value) => setState(() => _shelfArea = value),
              ),
            ),
            _SectionCard(
              title: '4. Own Product Facing',
              child: Column(
                children: [
                  ..._ownRows.asMap().entries.map(
                    (entry) => _OwnProductRowEditor(
                      key: ObjectKey(entry.value),
                      row: entry.value,
                      products: ownProducts,
                      onRemove: _ownRows.length == 1
                          ? null
                          : () => setState(() {
                              entry.value.dispose();
                              _ownRows.removeAt(entry.key);
                            }),
                      onChanged: () => setState(() {}),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () =>
                          setState(() => _ownRows.add(_OwnProductDraft())),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Own Product Row'),
                    ),
                  ),
                ],
              ),
            ),
            _SectionCard(
              title: '5. Missing SKU Summary',
              child: _MissingSkuSummary(rows: _ownRows),
            ),
            _SectionCard(
              title: '6. Competitor Shelf Presence',
              child: Column(
                children: [
                  if (_competitorRows.isEmpty)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('No competitor product recorded yet.'),
                    )
                  else
                    ..._competitorRows.asMap().entries.map(
                      (entry) => _CompetitorRowEditor(
                        key: ObjectKey(entry.value),
                        row: entry.value,
                        brands: competitorBrands,
                        productsForBrand: (brandId) =>
                            repository.getCompetitorProducts(brandId: brandId),
                        onRemove: () => setState(() {
                          entry.value.dispose();
                          _competitorRows.removeAt(entry.key);
                        }),
                        onChanged: () => setState(() {}),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(
                        () => _competitorRows.add(_CompetitorProductDraft()),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Competitor Product Row'),
                    ),
                  ),
                ],
              ),
            ),
            _SectionCard(
              title: '7. Shelf Issue',
              child: _EnumDropdown<PlanogramMainIssue>(
                label: 'Main Issue',
                value: _mainIssue,
                values: PlanogramMainIssue.values,
                labelOf: (value) => value.label,
                onChanged: (value) => setState(() => _mainIssue = value),
              ),
            ),
            _SectionCard(
              title: '8. Merchandiser Action Taken',
              child: _EnumDropdown<MerchandiserActionTaken>(
                label: 'Action Taken',
                value: _actionTaken,
                values: MerchandiserActionTaken.values,
                labelOf: (value) => value.label,
                onChanged: (value) => setState(() => _actionTaken = value),
              ),
            ),
            _SectionCard(
              title: '9. After Photo',
              child: _PhotoCapture(
                label: _requiresAfterPhoto
                    ? 'After photo required'
                    : 'After photo optional when no action is taken',
                captured: _afterPhotoCaptured,
                onCapture: () => setState(() => _afterPhotoCaptured = true),
              ),
            ),
            _SectionCard(
              title: '10. Compliance & Notes',
              child: Column(
                children: [
                  _EnumDropdown<PlanogramComplianceStatus>(
                    label: 'Compliance Status',
                    value: _complianceStatus,
                    values: PlanogramComplianceStatus.values,
                    labelOf: (value) => value.label,
                    onChanged: (value) =>
                        setState(() => _complianceStatus = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: _notesRequiredForNoAction
                          ? 'Notes (required — no action taken on identified issue)'
                          : 'Notes',
                      errorText:
                          _notesRequiredForNoAction &&
                              _notesController.text.trim().isEmpty
                          ? 'Notes required when no action taken on issue'
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            _SectionCard(
              title: '11. Submit',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _canSubmit
                        ? 'Ready to submit and queue.'
                        : 'Complete required audit fields to submit.',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.planogramChecks),
                    icon: const Icon(Icons.history_outlined),
                    label: const Text('View Planogram History'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_beforePhotoCaptured) {
      _showMessage('Please capture before shelf photo.');
      return;
    }
    if (_shelfArea == null) {
      _showMessage('Please select shelf area.');
      return;
    }
    if (_ownRows.isEmpty || !_ownRows.every((row) => row.isComplete)) {
      _showMessage('Please add at least one complete own product row.');
      return;
    }
    if (_mainIssue == null) {
      _showMessage('Please select main issue.');
      return;
    }
    if (_actionTaken == null) {
      _showMessage('Please select action taken.');
      return;
    }
    if (_notesRequiredForNoAction && _notesController.text.trim().isEmpty) {
      _showMessage('Notes required when no action taken on identified issue.');
      return;
    }
    if (_complianceStatus == null) {
      _showMessage('Please select compliance status.');
      return;
    }
    if (_requiresAfterPhoto && !_afterPhotoCaptured) {
      _showMessage('Please capture after shelf photo.');
      return;
    }
    final competitorRowsWithInput = _competitorRows.where(
      (row) =>
          row.brand != null ||
          row.product != null ||
          row.facingController.text.trim().isNotEmpty ||
          row.noteController.text.trim().isNotEmpty,
    );
    if (competitorRowsWithInput.any((row) => !row.isComplete)) {
      _showMessage(
        'Please complete or remove incomplete competitor product rows.',
      );
      return;
    }

    final ownRows = _ownRows.map((row) => row.toModel()).toList();
    final competitorRows = _competitorRows
        .where((row) => row.isComplete)
        .map((row) => row.toModel())
        .toList();
    final missingSkus = ownRows
        .where(
          (row) =>
              row.availability == ProductAvailability.no ||
              row.placementStatus == ProductPlacementStatus.notDisplayed,
        )
        .map((row) => row.productName)
        .toList(growable: false);

    final check = AppStateScope.of(context).submitPlanogramCheck(
      beforePhotoCaptured: _beforePhotoCaptured,
      shelfArea: _shelfArea!,
      ownProductRows: ownRows,
      competitorProductRows: competitorRows,
      mainIssue: _mainIssue!,
      actionTaken: _actionTaken!,
      afterPhotoCaptured: _afterPhotoCaptured,
      complianceStatus: _complianceStatus!,
      missingSkus: missingSkus,
      notes: _notesController.text,
    );
    if (check == null) {
      _showMessage('Unable to submit planogram check.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Planogram Check submitted and queued.')),
    );
    context.go(AppRoutes.store);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OwnProductDraft {
  final facingController = TextEditingController();
  Product? product;
  ProductAvailability? availability;
  ProductPlacementStatus? placementStatus;

  bool get isComplete =>
      product != null &&
      facingController.text.trim().isNotEmpty &&
      int.tryParse(facingController.text.trim()) != null &&
      int.parse(facingController.text.trim()) >= 0 &&
      availability != null &&
      placementStatus != null;

  PlanogramOwnProductRow toModel() {
    final selectedProduct = product!;
    return PlanogramOwnProductRow(
      productId: selectedProduct.id,
      productName: selectedProduct.name,
      sku: selectedProduct.sku,
      facingCount: int.parse(facingController.text.trim()),
      availability: availability!,
      placementStatus: placementStatus!,
    );
  }

  void dispose() {
    facingController.dispose();
  }
}

class _CompetitorProductDraft {
  final facingController = TextEditingController();
  final noteController = TextEditingController();
  Brand? brand;
  Product? product;

  bool get isComplete =>
      brand != null &&
      product != null &&
      facingController.text.trim().isNotEmpty &&
      int.tryParse(facingController.text.trim()) != null &&
      int.parse(facingController.text.trim()) >= 0;

  PlanogramCompetitorProductRow toModel() {
    final selectedBrand = brand!;
    final selectedProduct = product!;
    return PlanogramCompetitorProductRow(
      brandId: selectedBrand.id,
      brandName: selectedBrand.name,
      productId: selectedProduct.id,
      productName: selectedProduct.name,
      facingCount: int.parse(facingController.text.trim()),
      shelfDominanceNote: noteController.text.trim(),
    );
  }

  void dispose() {
    facingController.dispose();
    noteController.dispose();
  }
}

class _OwnProductRowEditor extends StatelessWidget {
  const _OwnProductRowEditor({
    required this.row,
    required this.products,
    required this.onChanged,
    this.onRemove,
    super.key,
  });

  final _OwnProductDraft row;
  final List<Product> products;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<Product>(
              initialValue: row.product,
              decoration: const InputDecoration(labelText: 'Own Product'),
              items: products
                  .map(
                    (product) => DropdownMenuItem(
                      value: product,
                      child: Text('${product.name} • ${product.sku}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                row.product = value;
                onChanged();
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: row.facingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Facing Count'),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 10),
            _EnumDropdown<ProductAvailability>(
              label: 'Availability',
              value: row.availability,
              values: ProductAvailability.values,
              labelOf: (value) => value.label,
              onChanged: (value) {
                row.availability = value;
                onChanged();
              },
            ),
            const SizedBox(height: 10),
            _EnumDropdown<ProductPlacementStatus>(
              label: 'Placement Status',
              value: row.placementStatus,
              values: ProductPlacementStatus.values,
              labelOf: (value) => value.label,
              onChanged: (value) {
                row.placementStatus = value;
                onChanged();
              },
            ),
            if (onRemove != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompetitorRowEditor extends StatelessWidget {
  const _CompetitorRowEditor({
    required this.row,
    required this.brands,
    required this.productsForBrand,
    required this.onChanged,
    required this.onRemove,
    super.key,
  });

  final _CompetitorProductDraft row;
  final List<Brand> brands;
  final List<Product> Function(String brandId) productsForBrand;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final products = row.brand == null
        ? <Product>[]
        : productsForBrand(row.brand!.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<Brand>(
              initialValue: row.brand,
              decoration: const InputDecoration(labelText: 'Competitor Brand'),
              items: brands
                  .map(
                    (brand) =>
                        DropdownMenuItem(value: brand, child: Text(brand.name)),
                  )
                  .toList(),
              onChanged: (value) {
                row.brand = value;
                row.product = null;
                onChanged();
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Product>(
              initialValue: row.product,
              decoration: const InputDecoration(
                labelText: 'Competitor Product',
              ),
              items: products
                  .map(
                    (product) => DropdownMenuItem(
                      value: product,
                      child: Text(product.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                row.product = value;
                onChanged();
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: row.facingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Facing Count'),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: row.noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Shelf Dominance Note',
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingSkuSummary extends StatelessWidget {
  const _MissingSkuSummary({required this.rows});

  final List<_OwnProductDraft> rows;

  @override
  Widget build(BuildContext context) {
    final missing = rows
        .where(
          (row) =>
              row.product != null &&
              (row.availability == ProductAvailability.no ||
                  row.placementStatus == ProductPlacementStatus.notDisplayed),
        )
        .map((row) => row.product!.name)
        .toList();

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        missing.isEmpty ? 'No missing SKU identified yet.' : missing.join(', '),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
            child,
          ],
        ),
      ),
    );
  }
}

class _ContextContent extends StatelessWidget {
  const _ContextContent({
    required this.customerName,
    required this.customerAddress,
    required this.visitStatus,
  });

  final String customerName;
  final String customerAddress;
  final String visitStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(customerName, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(customerAddress),
        const SizedBox(height: 8),
        Text(
          'Visit status: $visitStatus',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _PhotoCapture extends StatelessWidget {
  const _PhotoCapture({
    required this.label,
    required this.captured,
    required this.onCapture,
  });

  final String label;
  final bool captured;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: captured
                ? AppTheme.accent.withValues(alpha: 0.10)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: captured ? AppTheme.accent : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                captured
                    ? Icons.check_circle_outline
                    : Icons.camera_alt_outlined,
                color: captured ? AppTheme.accent : AppTheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  captured ? '$label captured.' : label,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: onCapture,
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(captured ? 'Retake Photo' : 'Take Photo'),
        ),
      ],
    );
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> values;
  final String Function(T value) labelOf;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: values
          .map(
            (value) =>
                DropdownMenuItem<T>(value: value, child: Text(labelOf(value))),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
