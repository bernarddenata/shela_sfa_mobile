enum SyncEventType {
  createdOnDevice('CREATED_ON_DEVICE'),
  queued('QUEUED'),
  syncStarted('SYNC_STARTED'),
  sentToServer('SENT_TO_SERVER'),
  syncSuccess('SYNC_SUCCESS'),
  syncFailed('SYNC_FAILED'),
  retryStarted('RETRY_STARTED'),
  cancelled('CANCELLED');

  const SyncEventType(this.label);

  final String label;
}

class SyncEvent {
  const SyncEvent({
    required this.eventType,
    required this.timestamp,
    this.message = '',
  });

  final SyncEventType eventType;
  final DateTime timestamp;
  final String message;
}
