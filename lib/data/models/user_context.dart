class UserContext {
  const UserContext({
    required this.userId,
    required this.username,
    required this.employeeId,
    required this.employeeName,
    required this.tenantId,
    required this.tenantName,
    required this.companyId,
    required this.companyName,
    required this.branchId,
    required this.branchName,
    required this.role,
    required this.appCode,
    required this.companyCode,
  });

  final String userId;
  final String username;
  final String employeeId;
  final String employeeName;
  final String tenantId;
  final String tenantName;
  final String companyId;
  final String companyName;
  final String branchId;
  final String branchName;
  final String role;
  final String appCode;
  final String companyCode;

  String get firstName => employeeName.split(' ').first;

  UserContext copyWith({String? username, String? companyCode}) {
    return UserContext(
      userId: userId,
      username: username ?? this.username,
      employeeId: employeeId,
      employeeName: employeeName,
      tenantId: tenantId,
      tenantName: tenantName,
      companyId: companyId,
      companyName: companyName,
      branchId: branchId,
      branchName: branchName,
      role: role,
      appCode: appCode,
      companyCode: companyCode ?? this.companyCode,
    );
  }
}
