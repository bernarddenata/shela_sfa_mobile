import 'sync_item.dart';

enum PromoComplianceStatus {
  installed('INSTALLED'),
  partiallyInstalled('PARTIALLY_INSTALLED'),
  notInstalled('NOT_INSTALLED');

  const PromoComplianceStatus(this.label);

  final String label;
}

class PromoProgram {
  const PromoProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.validUntil,
  });

  final String id;
  final String name;
  final String description;
  final DateTime validUntil;
}

class PromoCheck {
  const PromoCheck({
    required this.id,
    required this.promoId,
    required this.promoName,
    required this.visitId,
    required this.customerId,
    required this.employeeId,
    required this.branchId,
    required this.complianceStatus,
    required this.photoCaptured,
    required this.syncStatus,
    required this.createdAt,
    this.notes = '',
  });

  final String id;
  final String promoId;
  final String promoName;
  final String visitId;
  final String customerId;
  final String employeeId;
  final String branchId;
  final PromoComplianceStatus complianceStatus;
  final bool photoCaptured;
  final String notes;
  final SyncStatus syncStatus;
  final DateTime createdAt;
}
