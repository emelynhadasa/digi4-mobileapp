class Constant {
  static const String baseUrl = 'http://192.168.67.110:53346/api';
  static const String baseImageUrl = 'http://192.168.67.110:53346/Content';
  static const String loginUrl = '$baseUrl/login';
  static const String registerUrl = '$baseUrl/register';
  static Map<String, String> header = {
    'Host': '192.168.67.110:53346',
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  static const String dashboardUrl = '$baseUrl/dashboard';
  static const String assetUrl = '$baseUrl/assets';
  static const String repairRequestUrl = '$baseUrl/repair-requests';
  static const String repairRequestInstancesUrl =
      '$baseUrl/repair-requests/instances';
  static const String plantUrl = '$baseUrl/locator/plants';
  static const String cabinetUrl = '$baseUrl/locator/cabinets';
  static const String shelfUrl = '$baseUrl/locator/shelves';
  static const String instanceUrl = '$baseUrl/locator/instances';
  static const String assetInstaceUrl = '$baseUrl/instances';
  static const String bulkInstanceUrl = '$baseUrl/bulk';
}
