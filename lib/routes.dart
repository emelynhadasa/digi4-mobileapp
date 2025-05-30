import 'package:digi4_mobile/models/assets_model.dart';
import 'package:digi4_mobile/models/locator_model.dart';
import 'package:digi4_mobile/models/repair_request_model.dart';
import 'package:digi4_mobile/views/assets_bulk_page.dart';
import 'package:digi4_mobile/views/assets_create_page.dart';
import 'package:digi4_mobile/views/assets_detail_page.dart';
import 'package:digi4_mobile/views/assets_edit_page.dart';
import 'package:digi4_mobile/views/assets_page.dart';
import 'package:digi4_mobile/views/cabinet_edit_page.dart';
import 'package:digi4_mobile/views/cabinets_page.dart';
import 'package:digi4_mobile/views/home_page.dart';
import 'package:digi4_mobile/views/instances_create_page.dart';
import 'package:digi4_mobile/views/instances_page.dart';
import 'package:digi4_mobile/views/locator_add_page.dart';
import 'package:digi4_mobile/views/login_page.dart';
import 'package:digi4_mobile/views/main_page.dart';
import 'package:digi4_mobile/views/register_page.dart';
import 'package:digi4_mobile/views/repair_detail_page.dart';
import 'package:digi4_mobile/views/repair_new_page.dart';
import 'package:digi4_mobile/views/scan_page.dart';
import 'package:digi4_mobile/views/shelf_edit_page.dart';
import 'package:digi4_mobile/views/shelf_page.dart';
import 'package:digi4_mobile/views/shelf_stored_instance_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String home = '/home';
  static const String scan = '/scan';
  static const String createAsset = '/createAsset';
  static const String detailAsset = '/detailAsset';
  static const String editAsset = '/editAsset';
  static const String assetBulk = '/assetBulk';
  static const String detailRepair = '/detailRepair';
  static const String newRepair = '/newRepair';
  static const String cabinet = '/cabinet';
  static const String cabinetEdit = '/cabinetEdit';
  static const String shelf = '/shelf';
  static const String shelfEdit = '/shelfEdit';
  static const String shelfStored = '/shelfStored';
  static const String asset = '/asset';
  static const String instances = '/instances';
  static const String instancesCreate = '/instancesCreate';
  static const String plantsCreate = '/plantsCreate';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      main: (context) => const MainPage(),
      home: (context) => HomePage(),
      scan: (context) => const ScanPage(),
      asset: (context) => AssetsPage(),
      createAsset: (context) => CreateAssetPage(),
      detailAsset: (context) {
        final args = ModalRoute.of(context)!.settings.arguments;
        if (args is AssetsModel) {
          return AssetDetailPage(asset: args);
        } else if (args is int) {
          return AssetDetailPage(assetId: args);
        } else {
          return AssetDetailPage();
        }
      },
      editAsset: (context) {
        final args = ModalRoute.of(context)!.settings.arguments;
        if (args is AssetsModel) {
          return EditAssetPage(asset: args);
        } else if (args is int) {
          return EditAssetPage(assetId: args);
        } else {
          return EditAssetPage(); // Akan menampilkan pesan error "No asset data available"
        }
      },
      assetBulk: (context) => BulkOperationsPage(),
      detailRepair: (context) {
        final args = ModalRoute.of(context)!.settings.arguments;
        if (args is RepairRequestModel) {
          return RepairDetailPage(repairRequest: args);
        } else {
          // Fallback dengan dummy data jika tidak ada arguments
          return RepairDetailPage(
            repairRequest: RepairRequestModel(
              repairRequestId: 0,
              instanceId: 0,
              kpk: 'No KPK',
              remarks: 'No repair request data available',
              repairReqImage: null,
              status: 'Unknown',
              submittedByName: 'Unknown',
              updatedAt: DateTime.now(),
              instanceDisplay: 'Unknown Instance',
              repairImageBase64: null,
            ),
          );
        }
      },
      newRepair: (context) => NewRepairRequestPage(),
      cabinet: (context) => CabinetsPage(),
      cabinetEdit: (context) {
        // Ambil arguments dari Navigator
        final args = ModalRoute.of(context)?.settings.arguments;

        if (args is Map<String, dynamic>) {
          // Convert dari Map ke Cabinet object
          final Cabinet cabinet = Cabinet(
            cabinetId: args['cabinetId'] ?? 0,
            cabinetName: args['name'] ?? '',
            cabinetType: args['type'] ?? '',
          );

          return CabinetEditPage(
            cabinet: cabinet,
            plantId: args['plantId']?.toString() ?? '0',
          );
        } else {
          // Fallback dengan data dummy jika tidak ada arguments
          return CabinetEditPage(
            cabinet: Cabinet(
              cabinetId: 0,
              cabinetName: 'OpenCabinet=65',
              cabinetType: 'OpenCabinet',
            ),
            plantId: '0',
          );
        }
      },
      shelf: (context) => ShelfPage(),
      shelfEdit: (context) {
        // Ambil arguments dari Navigator
        final args = ModalRoute.of(context)?.settings.arguments;

        if (args is Map<String, dynamic>) {
          // Convert dari Map ke Shelf object
          final Shelf shelf = Shelf(
            shelfId: int.parse(args['shelfId']) ?? 0,
            shelfLabel: args['shelfLabel'] ?? '',
          );

          return ShelfEditPage(
            shelf: shelf,
            cabinetId: args['cabinetId']?.toString() ?? '0',
            cabinetName: args['cabinetName'],
          );
        } else {
          // Fallback dengan data dummy jika tidak ada arguments
          return ShelfEditPage(
            shelf: Shelf(shelfId: 0, shelfLabel: 'Shelf A'),
            cabinetId: '0',
            cabinetName: 'Unknown Cabinet',
          );
        }
      },
      shelfStored: (context) => StoredInstanceShelfPage(),
      instances: (context) => InstancesPage(),
      instancesCreate: (context) => InstanceCreatePage(),
      plantsCreate: (context) => LocatorAddPage(),
    };
  }
}
