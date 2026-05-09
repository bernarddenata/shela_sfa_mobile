import 'sync_item.dart';

enum PlanogramComplianceStatus {
  compliant('COMPLIANT'),
  partiallyCompliant('PARTIALLY_COMPLIANT'),
  notCompliant('NOT_COMPLIANT');

  const PlanogramComplianceStatus(this.label);

  final String label;
}

enum ShelfArea {
  frontShelf('FRONT_SHELF'),
  mainShelf('MAIN_SHELF'),
  checkoutArea('CHECKOUT_AREA'),
  promoArea('PROMO_AREA'),
  endCap('END_CAP'),
  other('OTHER');

  const ShelfArea(this.label);

  final String label;
}

enum ShelfLevel {
  eyeLevel('EYE_LEVEL'),
  topLevel('TOP_LEVEL'),
  middleLevel('MIDDLE_LEVEL'),
  bottomLevel('BOTTOM_LEVEL');

  const ShelfLevel(this.label);

  final String label;
}

enum ProductAvailability {
  yes('YES'),
  no('NO');

  const ProductAvailability(this.label);

  final String label;
}

enum ProductPlacementStatus {
  correct('CORRECT'),
  wrongPosition('WRONG_POSITION'),
  blocked('BLOCKED'),
  notDisplayed('NOT_DISPLAYED');

  const ProductPlacementStatus(this.label);

  final String label;
}

enum ShareOfShelfEstimate {
  dominatedByOwnProduct('DOMINATED_BY_OWN_PRODUCT'),
  balanced('BALANCED'),
  dominatedByCompetitor('DOMINATED_BY_COMPETITOR'),
  ownProductNotVisible('OWN_PRODUCT_NOT_VISIBLE');

  const ShareOfShelfEstimate(this.label);

  final String label;
}

enum PlanogramMainIssue {
  missingSku('MISSING_SKU'),
  lowFacing('LOW_FACING'),
  wrongPlacement('WRONG_PLACEMENT'),
  competitorDominance('COMPETITOR_DOMINANCE'),
  emptyShelf('EMPTY_SHELF'),
  priceTagMissing('PRICE_TAG_MISSING'),
  promoMaterialMissing('PROMO_MATERIAL_MISSING'),
  noIssue('NO_ISSUE');

  const PlanogramMainIssue(this.label);

  final String label;
}

enum RecommendedAction {
  restock('RESTOCK'),
  rearrangeDisplay('REARRANGE_DISPLAY'),
  addPromoMaterial('ADD_PROMO_MATERIAL'),
  negotiateDisplaySpace('NEGOTIATE_DISPLAY_SPACE'),
  reportToSupervisor('REPORT_TO_SUPERVISOR'),
  noAction('NO_ACTION');

  const RecommendedAction(this.label);

  final String label;
}

enum MerchandiserActionTaken {
  rearrangedProduct('REARRANGED_PRODUCT'),
  addedProductToShelf('ADDED_PRODUCT_TO_SHELF'),
  addedPromoMaterial('ADDED_PROMO_MATERIAL'),
  cleanedDisplay('CLEANED_DISPLAY'),
  spokeToStoreOwner('SPOKE_TO_STORE_OWNER'),
  noActionTaken('NO_ACTION_TAKEN');

  const MerchandiserActionTaken(this.label);

  final String label;
}

class PlanogramOwnProductRow {
  const PlanogramOwnProductRow({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.facingCount,
    required this.availability,
    required this.placementStatus,
    this.uomId = 'uom_pcs',
    this.uomCode = 'PCS',
  });

  final String productId;
  final String productName;
  final String sku;
  final String uomId;
  final String uomCode;
  final int facingCount;
  final ProductAvailability availability;
  final ProductPlacementStatus placementStatus;
}

class PlanogramCompetitorProductRow {
  const PlanogramCompetitorProductRow({
    required this.brandId,
    required this.brandName,
    required this.productId,
    required this.productName,
    required this.facingCount,
    this.uomId = 'uom_pcs',
    this.uomCode = 'PCS',
    this.shelfDominanceNote = '',
  });

  final String brandId;
  final String brandName;
  final String productId;
  final String productName;
  final String uomId;
  final String uomCode;
  final int facingCount;
  final String shelfDominanceNote;
}

class PlanogramCheck {
  const PlanogramCheck({
    required this.id,
    required this.visitId,
    required this.customerId,
    required this.employeeId,
    required this.branchId,
    required this.beforePhotoCaptured,
    required this.shelfArea,
    required this.ownProductRows,
    required this.missingSkus,
    required this.competitorProductRows,
    required this.mainIssue,
    required this.actionTaken,
    required this.afterPhotoCaptured,
    required this.complianceStatus,
    required this.syncStatus,
    required this.createdAt,
    this.shelfLevel = ShelfLevel.middleLevel,
    this.shareOfShelfEstimate = ShareOfShelfEstimate.balanced,
    this.recommendedAction = RecommendedAction.noAction,
    this.notes = '',
  });

  final String id;
  final String visitId;
  final String customerId;
  final String employeeId;
  final String branchId;
  final bool beforePhotoCaptured;
  final ShelfArea shelfArea;
  final ShelfLevel shelfLevel;
  final List<PlanogramOwnProductRow> ownProductRows;
  final List<String> missingSkus;
  final List<PlanogramCompetitorProductRow> competitorProductRows;
  final ShareOfShelfEstimate shareOfShelfEstimate;
  final PlanogramMainIssue mainIssue;
  final RecommendedAction recommendedAction;
  final MerchandiserActionTaken actionTaken;
  final bool afterPhotoCaptured;
  final PlanogramComplianceStatus complianceStatus;
  final String notes;
  final SyncStatus syncStatus;
  final DateTime createdAt;

  int get facingCount =>
      ownProductRows.fold<int>(0, (total, row) => total + row.facingCount);

  bool get photoCaptured => beforePhotoCaptured;
}
