enum VisitStatus {
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const VisitStatus(this.label);

  final String label;
}

class Visit {
  const Visit({
    required this.id,
    required this.callPlanId,
    required this.customerId,
    required this.employeeId,
    required this.branchId,
    required this.status,
    required this.checkInAt,
    required this.latitude,
    required this.longitude,
    required this.photoCaptured,
    required this.fakeGpsDetected,
    this.checkOutAt,
  });

  final String id;
  final String callPlanId;
  final String customerId;
  final String employeeId;
  final String branchId;
  final VisitStatus status;
  final DateTime checkInAt;
  final double latitude;
  final double longitude;
  final bool photoCaptured;
  final bool fakeGpsDetected;
  final DateTime? checkOutAt;

  Visit copyWith({VisitStatus? status, DateTime? checkOutAt}) {
    return Visit(
      id: id,
      callPlanId: callPlanId,
      customerId: customerId,
      employeeId: employeeId,
      branchId: branchId,
      status: status ?? this.status,
      checkInAt: checkInAt,
      latitude: latitude,
      longitude: longitude,
      photoCaptured: photoCaptured,
      fakeGpsDetected: fakeGpsDetected,
      checkOutAt: checkOutAt ?? this.checkOutAt,
    );
  }
}
