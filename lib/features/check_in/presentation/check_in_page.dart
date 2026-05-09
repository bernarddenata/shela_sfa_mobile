import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/call_plan.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/app_state_scope.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({required this.callPlanId, super.key});

  final String callPlanId;

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  bool _locationCaptured = false;
  bool _locationLoading = false;
  final bool _fakeGpsDetected = false;
  bool _photoCaptured = false;
  double? _latitude;
  double? _longitude;
  DateTime? _locationCapturedAt;
  String? _autoCaptureCallPlanId;

  bool get _canCheckIn =>
      _locationCaptured && !_fakeGpsDetected && _photoCaptured;

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final callPlan = repository.getCallPlanById(widget.callPlanId);
    final customer = callPlan == null
        ? null
        : repository.getCustomerById(callPlan.customerId);

    if (callPlan == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Check-in')),
        body: const Center(child: Text('Call plan was not found.')),
      );
    }

    if (_autoCaptureCallPlanId != callPlan.id) {
      _autoCaptureCallPlanId = callPlan.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _captureLocation(customer);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Check-in')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _CustomerHeader(customer: customer, callPlan: callPlan),
            const SizedBox(height: 14),
            _LocationCard(
              isLoading: _locationLoading,
              isCaptured: _locationCaptured,
              latitude: _latitude,
              longitude: _longitude,
              capturedAt: _locationCapturedAt,
              onRefresh: _locationLoading
                  ? null
                  : () => _captureLocation(customer),
            ),
            const SizedBox(height: 12),
            _FakeGpsCard(fakeGpsDetected: _fakeGpsDetected),
            const SizedBox(height: 12),
            _PhotoCard(photoCaptured: _photoCaptured, onCapture: _capturePhoto),
            const SizedBox(height: 12),
            _RequirementChecklist(
              locationCaptured: _locationCaptured,
              fakeGpsDetected: _fakeGpsDetected,
              photoCaptured: _photoCaptured,
            ),
            const SizedBox(height: 16),
            if (!_canCheckIn)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Complete all check-in requirements to continue.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canCheckIn
                    ? () => _checkIn(callPlan: callPlan, customer: customer)
                    : null,
                child: const Text('Check In'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureLocation(Customer customer) async {
    setState(() {
      _locationLoading = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }

    setState(() {
      _locationCaptured = true;
      _locationLoading = false;
      _latitude = customer.latitude;
      _longitude = customer.longitude;
      _locationCapturedAt = DateTime.now();
    });
  }

  void _capturePhoto() {
    setState(() {
      _photoCaptured = true;
    });
  }

  void _checkIn({required CallPlan callPlan, required Customer customer}) {
    final visit = AppStateScope.of(context).checkIn(
      callPlanId: callPlan.id,
      latitude: _latitude ?? customer.latitude,
      longitude: _longitude ?? customer.longitude,
      photoCaptured: _photoCaptured,
      fakeGpsDetected: _fakeGpsDetected,
    );

    if (visit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to complete check-in.')),
      );
      return;
    }

    context.go(AppRoutes.store);
  }
}

class _CustomerHeader extends StatelessWidget {
  const _CustomerHeader({required this.customer, required this.callPlan});

  final Customer customer;
  final CallPlan callPlan;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.name,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              customer.address,
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            StatusChip(label: callPlan.status.label, color: AppTheme.warning),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.isLoading,
    required this.isCaptured,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    required this.onRefresh,
  });

  final bool isLoading;
  final bool isCaptured;
  final double? latitude;
  final double? longitude;
  final DateTime? capturedAt;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = isLoading
        ? 'Getting your location...'
        : isCaptured
        ? 'Location captured'
        : 'Waiting for location';
    final statusColor = isCaptured ? AppTheme.accent : AppTheme.warning;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.my_location, color: AppTheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Location',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StatusChip(label: status, color: statusColor),
            if (isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(minHeight: 3),
            ],
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Coordinate',
              value: latitude == null || longitude == null
                  ? '-'
                  : '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}',
            ),
            const SizedBox(height: 8),
            const _InfoRow(label: 'Distance', value: '0 m from store'),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Captured at',
              value: capturedAt == null ? '-' : _formatTime(capturedAt!),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Location'),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _FakeGpsCard extends StatelessWidget {
  const _FakeGpsCard({required this.fakeGpsDetected});

  final bool fakeGpsDetected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security_outlined, color: AppTheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Anti Fake GPS',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StatusChip(
              label: fakeGpsDetected ? 'Detected' : 'Not Detected',
              color: fakeGpsDetected ? AppTheme.danger : AppTheme.accent,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Fake GPS status',
              value: fakeGpsDetected ? 'Detected' : 'Not Detected',
            ),
            const SizedBox(height: 8),
            const _InfoRow(label: 'Device integrity', value: 'Normal'),
          ],
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.photoCaptured, required this.onCapture});

  final bool photoCaptured;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_a_photo_outlined, color: AppTheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Selfie / Store Photo',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StatusChip(
              label: photoCaptured ? 'Photo captured' : 'Photo required',
              color: photoCaptured ? AppTheme.accent : AppTheme.warning,
            ),
            const SizedBox(height: 12),
            if (photoCaptured)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        color: AppTheme.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Selfie/store photo saved locally for check-in.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4B5563),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                'Selfie or store photo is required before check-in.',
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onCapture,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(
                photoCaptured
                    ? 'Retake Selfie / Store Photo'
                    : 'Take Selfie / Store Photo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementChecklist extends StatelessWidget {
  const _RequirementChecklist({
    required this.locationCaptured,
    required this.fakeGpsDetected,
    required this.photoCaptured,
  });

  final bool locationCaptured;
  final bool fakeGpsDetected;
  final bool photoCaptured;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Check-in Requirements',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            _ChecklistItem(
              label: 'Location captured',
              checked: locationCaptured,
            ),
            const SizedBox(height: 10),
            _ChecklistItem(
              label: 'Fake GPS not detected',
              checked: !fakeGpsDetected,
            ),
            const SizedBox(height: 10),
            _ChecklistItem(
              label: 'Selfie/store photo captured',
              checked: photoCaptured,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.label, required this.checked});

  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          checked ? Icons.check_circle : Icons.radio_button_unchecked,
          color: checked ? AppTheme.accent : const Color(0xFF9CA3AF),
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF374151),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104,
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1F2937),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
