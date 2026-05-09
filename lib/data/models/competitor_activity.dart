import 'sync_item.dart';

enum CompetitorActivityType {
  discount('DISCOUNT'),
  bundling('BUNDLING'),
  buyOneGetOne('BUY_1_GET_1'),
  freeGift('FREE_GIFT'),
  priceCut('PRICE_CUT'),
  displayPromo('DISPLAY_PROMO'),
  newProduct('NEW_PRODUCT');

  const CompetitorActivityType(this.label);

  final String label;
}

class CompetitorActivity {
  const CompetitorActivity({
    required this.id,
    required this.visitId,
    required this.customerId,
    required this.employeeId,
    required this.branchId,
    required this.competitorBrandId,
    required this.competitorBrand,
    required this.competitorProductId,
    required this.competitorProduct,
    required this.activityType,
    required this.photoCaptured,
    required this.syncStatus,
    required this.createdAt,
    this.price,
    this.promoDescription = '',
    this.notes = '',
  });

  final String id;
  final String visitId;
  final String customerId;
  final String employeeId;
  final String branchId;
  final String competitorBrandId;
  final String competitorBrand;
  final String competitorProductId;
  final String competitorProduct;
  final CompetitorActivityType activityType;
  final int? price;
  final String promoDescription;
  final bool photoCaptured;
  final String notes;
  final SyncStatus syncStatus;
  final DateTime createdAt;
}
