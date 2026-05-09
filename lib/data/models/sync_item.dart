enum SyncStatus {
  draft('DRAFT'),
  queued('QUEUED'),
  syncing('SYNCING'),
  synced('SYNCED'),
  failed('FAILED'),
  conflict('CONFLICT'),
  cancelled('CANCELLED');

  const SyncStatus(this.label);

  final String label;
}

enum SyncItemType {
  visitCheckIn('VISIT_CHECK_IN'),
  visitCheckOut('VISIT_CHECK_OUT'),
  regularOrder('REGULAR_ORDER'),
  canvasOrder('CANVAS_ORDER'),
  returnOrder('RETURN_ORDER'),
  returnSwapOrder('RETURN_SWAP_ORDER'),
  promoCheck('PROMO_CHECK'),
  competitorActivity('COMPETITOR_ACTIVITY'),
  planogramCheck('PLANOGRAM_CHECK'),
  stockCheck('STOCK_CHECK'),
  visitNote('VISIT_NOTE'),
  storePhoto('STORE_PHOTO');

  const SyncItemType(this.label);

  final String label;
}

class SyncItem {
  const SyncItem({
    required this.id,
    required this.type,
    required this.referenceId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.syncedAt,
    this.errorMessage,
  });

  final String id;
  final SyncItemType type;
  final String referenceId;
  final String title;
  final String description;
  final SyncStatus status;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final String? errorMessage;

  SyncItem copyWith({
    SyncStatus? status,
    DateTime? syncedAt,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return SyncItem(
      id: id,
      type: type,
      referenceId: referenceId,
      title: title,
      description: description,
      status: status ?? this.status,
      createdAt: createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
