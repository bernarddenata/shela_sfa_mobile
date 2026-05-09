import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../data/models/promo_check.dart';
import '../../../data/repositories/app_state_scope.dart';

class PromoCheckPage extends StatefulWidget {
  const PromoCheckPage({super.key});

  @override
  State<PromoCheckPage> createState() => _PromoCheckPageState();
}

class _PromoCheckPageState extends State<PromoCheckPage> {
  final _notesController = TextEditingController();
  String? _promoId;
  PromoComplianceStatus? _complianceStatus;
  bool _photoCaptured = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _promoId != null && _complianceStatus != null && _photoCaptured;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final visit = repository.activeVisit;
    final customer = visit == null
        ? null
        : repository.getCustomerById(visit.customerId);

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Promo Check')),
        body: const Center(
          child: Text('Please check in before recording store activity.'),
        ),
      );
    }

    final promos = repository.getPromoPrograms();

    return Scaffold(
      appBar: AppBar(title: const Text('Promo Check')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _canSubmit ? _submit : null,
            child: const Text('Submit Promo Check'),
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
            DropdownButtonFormField<String>(
              initialValue: _promoId,
              decoration: const InputDecoration(labelText: 'Active Promo'),
              items: promos
                  .map(
                    (promo) => DropdownMenuItem(
                      value: promo.id,
                      child: Text(promo.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _promoId = value),
            ),
            if (_promoId != null) ...[
              const SizedBox(height: 10),
              _PromoDescriptionCard(
                promo: repository.getPromoProgramById(_promoId!)!,
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<PromoComplianceStatus>(
              initialValue: _complianceStatus,
              decoration: const InputDecoration(
                labelText: 'Promo Compliance Status',
              ),
              items: PromoComplianceStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _complianceStatus = value),
            ),
            const SizedBox(height: 12),
            _PhotoCard(
              title: 'Promo Photo',
              buttonLabel: _photoCaptured
                  ? 'Retake Promo Photo'
                  : 'Take Promo Photo',
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
              onPressed: () => context.push(AppRoutes.promoChecks),
              icon: const Icon(Icons.history_outlined),
              label: const Text('View Promo Check History'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_promoId == null) {
      _showMessage('Please select a promo.');
      return;
    }
    if (_complianceStatus == null) {
      _showMessage('Please select promo compliance status.');
      return;
    }
    if (!_photoCaptured) {
      _showMessage('Please capture promo photo.');
      return;
    }

    final promoCheck = AppStateScope.of(context).submitPromoCheck(
      promoId: _promoId!,
      complianceStatus: _complianceStatus!,
      photoCaptured: _photoCaptured,
      notes: _notesController.text.trim(),
    );
    if (promoCheck == null) {
      _showMessage('Unable to submit promo check.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Promo Check submitted and queued.')),
    );
    context.go(AppRoutes.store);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

class _PromoDescriptionCard extends StatelessWidget {
  const _PromoDescriptionCard({required this.promo});

  final PromoProgram promo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              promo.description,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Valid until ${DateFormatters.compactDate(promo.validUntil)}'),
          ],
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.title,
    required this.buttonLabel,
    required this.photoCaptured,
    required this.onCapture,
  });

  final String title;
  final String buttonLabel;
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
              title,
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
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
