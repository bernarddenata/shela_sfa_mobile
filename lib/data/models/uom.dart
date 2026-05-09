class Uom {
  const Uom({
    required this.id,
    required this.code,
    required this.name,
  });

  final String id;
  final String code;
  final String name;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Uom && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
