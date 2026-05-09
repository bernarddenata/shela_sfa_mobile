import 'sync_item.dart';

enum SalesOrderType {
  regular('REGULAR_ORDER', 'Regular Order'),
  canvas('CANVAS_ORDER', 'Canvas Order');

  const SalesOrderType(this.code, this.label);

  final String code;
  final String label;
}

class SalesOrderItem {
  const SalesOrderItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.price,
    this.uomId = 'uom_pcs',
    this.uomCode = 'PCS',
  });

  final String productId;
  final String productName;
  final String sku;
  final String uomId;
  final String uomCode;
  final int quantity;
  final int price;

  int get subtotal => quantity * price;
}

class SalesOrder {
  const SalesOrder({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.visitId,
    required this.customerId,
    required this.employeeId,
    required this.branchId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.syncStatus,
    required this.createdAt,
  });

  final String id;
  final String orderNumber;
  final SalesOrderType orderType;
  final String visitId;
  final String customerId;
  final String employeeId;
  final String branchId;
  final List<SalesOrderItem> items;
  final int subtotal;
  final int discount;
  final int grandTotal;
  final SyncStatus syncStatus;
  final DateTime createdAt;
}
