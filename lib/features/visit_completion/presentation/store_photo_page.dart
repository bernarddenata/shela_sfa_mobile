import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/store_photo.dart';
import '../../../data/repositories/app_state_scope.dart';

class StorePhotoPage extends StatefulWidget {
  const StorePhotoPage({super.key});

  @override
  State<StorePhotoPage> createState() => _StorePhotoPageState();
}

class _StorePhotoPageState extends State<StorePhotoPage> {
  final _notesController = TextEditingController();
  StorePhotoType? _photoType;
  bool _photoCaptured = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSave => _photoType != null && _photoCaptured;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final visit = repository.activeVisit;
    final customer = visit == null
        ? null
        : repository.getCustomerById(visit.customerId);

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Store Photo')),
        body: const Center(
          child: Text('Please check in before recording store activity.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Store Photo')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _canSave ? _savePhoto : null,
            icon: const Icon(Icons.cloud_queue_outlined),
            label: const Text('Save Photo'),
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
            DropdownButtonFormField<StorePhotoType>(
              initialValue: _photoType,
              decoration: const InputDecoration(labelText: 'Photo Type'),
              items: StorePhotoType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _photoType = value),
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
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            if (!_canSave)
              const Text(
                'Select a photo type and capture a store photo to continue.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _savePhoto() {
    if (_photoType == null) {
      _showMessage('Please select photo type.');
      return;
    }
    if (!_photoCaptured) {
      _showMessage('Please capture store photo.');
      return;
    }

    final photo = AppStateScope.of(context).saveStorePhoto(
      photoType: _photoType!,
      photoCaptured: _photoCaptured,
      notes: _notesController.text,
    );

    if (photo == null) {
      _showMessage('Unable to save store photo.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Store Photo saved and queued.')),
    );
    context.go(AppRoutes.store);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
              'Photo Evidence',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: photoCaptured
                    ? AppTheme.accent.withValues(alpha: 0.10)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: photoCaptured
                      ? AppTheme.accent
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    photoCaptured
                        ? Icons.check_circle_outline
                        : Icons.photo_camera_outlined,
                    color: photoCaptured ? AppTheme.accent : AppTheme.primary,
                    size: 42,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    photoCaptured
                        ? 'Photo captured'
                        : 'Store photo is required.',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onCapture,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(photoCaptured ? 'Retake Photo' : 'Take Photo'),
            ),
          ],
        ),
      ),
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
