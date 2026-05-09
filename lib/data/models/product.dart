enum ProductType {
  ownProduct('OWN_PRODUCT'),
  competitorProduct('COMPETITOR_PRODUCT');

  const ProductType(this.label);

  final String label;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.brandId,
    required this.brandName,
    required this.productType,
    required this.category,
    required this.price,
    required this.canvasStock,
    required this.isSellable,
  });

  final String id;
  final String name;
  final String sku;
  final String brandId;
  final String brandName;
  final ProductType productType;
  final String category;
  final int price;
  final int canvasStock;
  final bool isSellable;

  Product copyWith({int? canvasStock}) {
    return Product(
      id: id,
      name: name,
      sku: sku,
      brandId: brandId,
      brandName: brandName,
      productType: productType,
      category: category,
      price: price,
      canvasStock: canvasStock ?? this.canvasStock,
      isSellable: isSellable,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
