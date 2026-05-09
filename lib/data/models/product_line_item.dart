class ProductLineItem {
  const ProductLineItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.uomId,
    required this.uomCode,
    required this.qty,
    required this.price,
  });

  final String productId;
  final String productName;
  final String sku;
  final String uomId;
  final String uomCode;
  final int qty;
  final int price;

  int get subtotal => qty * price;
}
