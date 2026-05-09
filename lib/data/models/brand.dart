enum BrandType {
  ownBrand('OWN_BRAND'),
  competitorBrand('COMPETITOR_BRAND');

  const BrandType(this.label);

  final String label;
}

enum BrandStatus {
  active('ACTIVE'),
  inactive('INACTIVE');

  const BrandStatus(this.label);

  final String label;
}

class Brand {
  const Brand({
    required this.id,
    required this.name,
    required this.brandType,
    required this.status,
  });

  final String id;
  final String name;
  final BrandType brandType;
  final BrandStatus status;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Brand && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
