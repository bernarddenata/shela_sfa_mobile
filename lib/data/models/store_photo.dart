import 'sync_item.dart';

enum StorePhotoType {
  frontStorePhoto('FRONT_STORE_PHOTO'),
  shelfPhoto('SHELF_PHOTO'),
  promoDisplayPhoto('PROMO_DISPLAY_PHOTO'),
  competitorPhoto('COMPETITOR_PHOTO'),
  returnProductPhoto('RETURN_PRODUCT_PHOTO'),
  other('OTHER');

  const StorePhotoType(this.label);

  final String label;
}

class StorePhoto {
  const StorePhoto({
    required this.id,
    required this.visitId,
    required this.customerId,
    required this.employeeId,
    required this.branchId,
    required this.photoType,
    required this.photoCaptured,
    required this.syncStatus,
    required this.createdAt,
    this.notes = '',
  });

  final String id;
  final String visitId;
  final String customerId;
  final String employeeId;
  final String branchId;
  final StorePhotoType photoType;
  final bool photoCaptured;
  final String notes;
  final SyncStatus syncStatus;
  final DateTime createdAt;
}
