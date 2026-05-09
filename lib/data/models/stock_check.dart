import 'sync_item.dart';

enum StockStatus {
  available('AVAILABLE'),
  lowStock('LOW_STOCK'),
  outOfStock('OUT_OF_STOCK');

  const StockStatus(this.label);

  final String label;
}

class StockCheckItem {
  const StockCheckItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.status,
  });

  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final StockStatus status;
}

class StockCheck {
  const StockCheck({
    required this.id,
    required this.visitId,
    required this.customerId,
    required this.employeeId,
    required this.branchId,
    required this.items,
    required this.syncStatus,
    required this.createdAt,
    this.notes = '',
  });

  final String id;
  final String visitId;
  final String customerId;
  final String employeeId;
  final String branchId;
  final List<StockCheckItem> items;
  final String notes;
  final SyncStatus syncStatus;
  final DateTime createdAt;
}
