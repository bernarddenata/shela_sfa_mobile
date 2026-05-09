import 'sync_item.dart';

enum VisitResult {
  orderCreated('ORDER_CREATED'),
  noOrder('NO_ORDER'),
  storeClosed('STORE_CLOSED'),
  ownerNotAvailable('OWNER_NOT_AVAILABLE'),
  stockFull('STOCK_FULL'),
  competitorDominant('COMPETITOR_DOMINANT'),
  other('OTHER');

  const VisitResult(this.label);

  final String label;
}

class VisitNote {
  const VisitNote({
    required this.id,
    required this.visitId,
    required this.customerId,
    required this.employeeId,
    required this.branchId,
    required this.result,
    required this.syncStatus,
    required this.createdAt,
    this.notes = '',
    this.followUpDate,
  });

  final String id;
  final String visitId;
  final String customerId;
  final String employeeId;
  final String branchId;
  final VisitResult result;
  final String notes;
  final DateTime? followUpDate;
  final SyncStatus syncStatus;
  final DateTime createdAt;
}
