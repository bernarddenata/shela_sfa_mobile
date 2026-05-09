class Customer {
  const Customer({
    required this.id,
    required this.branchId,
    required this.name,
    required this.address,
    required this.phone,
    required this.lastVisit,
    required this.lastOrderAmount,
    required this.latitude,
    required this.longitude,
    this.customerType = 'Retail Store',
    this.status = 'Active',
    this.creditLimit = 5000000,
    this.outstandingAmount = 0,
    this.paymentStatus = 'Good',
    this.notes = 'Reliable outlet with regular Nabati purchases.',
  });

  final String id;
  final String branchId;
  final String name;
  final String address;
  final String phone;
  final DateTime lastVisit;
  final int lastOrderAmount;
  final double latitude;
  final double longitude;
  final String customerType;
  final String status;
  final int creditLimit;
  final int outstandingAmount;
  final String paymentStatus;
  final String notes;
}
