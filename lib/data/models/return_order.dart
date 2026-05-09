import 'sync_item.dart';

enum ReturnOrderType {
  returnOrder('RETURN_ORDER', 'Return Order'),
  returnSwap('RETURN_SWAP_ORDER', 'Return Swap Order');

  const ReturnOrderType(this.code, this.label);

  final String code;
  final String label;
}

class ReturnOrderItem {
  const ReturnOrderItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    this.uomId = 'uom_pcs',
    this.uomCode = 'PCS',
  });

  final String productId;
  final String productName;
  final String sku;
  final String uomId;
  final String uomCode;
  final int quantity;
}

class ReturnOrder {
  const ReturnOrder({
    required this.id,
    required this.returnNumber,
    required this.returnType,
    required this.visitId,
    required this.customerId,
    required this.employeeId,
    required this.branchId,
    required this.reason,
    required this.photoCaptured,
    required this.syncStatus,
    required this.createdAt,
    this.items = const [],
    this.returnedItem,
    this.replacementItem,
    this.notes = '',
  });

  final String id;
  final String returnNumber;
  final ReturnOrderType returnType;
  final String visitId;
  final String customerId;
  final String employeeId;
  final String branchId;
  final List<ReturnOrderItem> items;
  final ReturnOrderItem? returnedItem;
  final ReturnOrderItem? replacementItem;
  final String reason;
  final String notes;
  final bool photoCaptured;
  final SyncStatus syncStatus;
  final DateTime createdAt;
}
