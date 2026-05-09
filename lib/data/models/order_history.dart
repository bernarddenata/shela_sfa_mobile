import 'sales_order.dart';
import 'sync_item.dart';

class OrderHistory {
  const OrderHistory({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.customerId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.syncStatus,
    required this.createdAt,
    this.visitId = '-',
  });

  final String id;
  final String orderNumber;
  final SalesOrderType orderType;
  final String customerId;
  final String visitId;
  final List<SalesOrderItem> items;
  final int subtotal;
  final int discount;
  final int grandTotal;
  final SyncStatus syncStatus;
  final DateTime createdAt;
}
