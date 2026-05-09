import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/models/visit_note.dart';
import '../../../data/repositories/app_state_scope.dart';

class VisitNotesPage extends StatefulWidget {
  const VisitNotesPage({super.key});

  @override
  State<VisitNotesPage> createState() => _VisitNotesPageState();
}

class _VisitNotesPageState extends State<VisitNotesPage> {
  final _notesController = TextEditingController();
  final _followUpController = TextEditingController();
  VisitResult? _result;

  @override
  void dispose() {
    _notesController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _result != null &&
      (_result != VisitResult.other || _notesController.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final visit = repository.activeVisit;
    final customer = visit == null
        ? null
        : repository.getCustomerById(visit.customerId);

    if (visit == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visit Notes')),
        body: const Center(
          child: Text('Please check in before recording store activity.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Visit Notes')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _canSave ? _saveNote : null,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Note'),
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
            DropdownButtonFormField<VisitResult>(
              initialValue: _result,
              decoration: const InputDecoration(labelText: 'Visit Result'),
              items: VisitResult.values
                  .map(
                    (result) => DropdownMenuItem(
                      value: result,
                      child: Text(result.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _result = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: _result == VisitResult.other
                    ? 'Notes required for Other'
                    : 'Notes',
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _followUpController,
              decoration: const InputDecoration(
                labelText: 'Next Follow-up Date',
                hintText: 'Optional, e.g. 2026-05-12',
                prefixIcon: Icon(Icons.event_outlined),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Notes are saved locally first and queued for sync.',
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

  void _saveNote() {
    if (_result == null) {
      _showMessage('Please select visit result.');
      return;
    }
    if (_result == VisitResult.other && _notesController.text.trim().isEmpty) {
      _showMessage('Please add notes for Other result.');
      return;
    }

    final followUpText = _followUpController.text.trim();
    final note = AppStateScope.of(context).saveVisitNote(
      result: _result!,
      notes: _notesController.text,
      followUpDate: followUpText.isEmpty
          ? null
          : DateTime.tryParse(followUpText),
    );

    if (note == null) {
      _showMessage('Unable to save visit note.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visit Note saved and queued.')),
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
