enum CallPlanStatus {
  notStarted('NOT_STARTED'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  missed('MISSED');

  const CallPlanStatus(this.label);

  final String label;
}

class CallPlan {
  const CallPlan({
    required this.id,
    required this.employeeId,
    required this.customerId,
    required this.branchId,
    required this.plannedDate,
    required this.plannedSequence,
    required this.status,
  });

  final String id;
  final String employeeId;
  final String customerId;
  final String branchId;
  final DateTime plannedDate;
  final int plannedSequence;
  final CallPlanStatus status;

  CallPlan copyWith({CallPlanStatus? status}) {
    return CallPlan(
      id: id,
      employeeId: employeeId,
      customerId: customerId,
      branchId: branchId,
      plannedDate: plannedDate,
      plannedSequence: plannedSequence,
      status: status ?? this.status,
    );
  }
}
