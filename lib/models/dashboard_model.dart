class DashboardModel {
  String userName;
  int roleId;
  List<dynamic> lowStock;
  List<dynamic> expiringWarranties;
  int pendingPurchaseCount;
  int totalAssets;
  int totalInstances;
  int openRepairCount;
  int ongoingPurchaseCount;
  List<dynamic> recentConsumables;
  List<dynamic> recentReusables;

  DashboardModel({
    required this.userName,
    required this.roleId,
    required this.lowStock,
    required this.expiringWarranties,
    required this.pendingPurchaseCount,
    required this.totalAssets,
    required this.totalInstances,
    required this.openRepairCount,
    required this.ongoingPurchaseCount,
    required this.recentConsumables,
    required this.recentReusables,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    print('=== DASHBOARD MODEL DEBUG ===');
    print('Raw JSON: $json');
    print('RecentReusables type: ${json['RecentReusables'].runtimeType}');
    print('RecentReusables data: ${json['RecentReusables']}');

    return DashboardModel(
      userName: json['UserName'] ?? 'User',
      roleId: json['RoleId'] ?? 0,
      lowStock: json['LowStock'] ?? [],
      expiringWarranties: json['ExpiringWarranties'] ?? [],
      pendingPurchaseCount: json['PendingPurchaseCount'] ?? 0,
      totalAssets: json['TotalAssets'] ?? 0,
      totalInstances: json['TotalInstances'] ?? 0,
      openRepairCount: json['OpenRepairCount'] ?? 0,
      ongoingPurchaseCount: json['OngoingPurchaseCount'] ?? 0,
      recentConsumables: json['RecentConsumables'] ?? [],
      recentReusables: json['RecentReusables'] ?? [],
    );
  }
}
