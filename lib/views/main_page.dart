import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/views/assets_page.dart';
import 'package:digi4_mobile/views/home_page.dart';
import 'package:digi4_mobile/views/locator_page.dart';
import 'package:digi4_mobile/views/repair_page.dart';
import 'package:digi4_mobile/views/scan_page.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  List<PersistentTabConfig> _tabs(BuildContext context) => [
    PersistentTabConfig(
      screen: HomePage(),
      item: ItemConfig(
        icon: Icon(Icons.home),
        title: 'Dashboard',
        iconSize: 32,
        activeColorSecondary: AppColors.background,
        activeForegroundColor: AppColors.background,
        inactiveBackgroundColor: AppColors.textSecondary,
        inactiveForegroundColor: AppColors.textSecondary,
      ),
    ),
    PersistentTabConfig(
      screen: AssetsPage(),
      item: ItemConfig(
        icon: Icon(Icons.inventory),
        title: 'Asset',
        iconSize: 32,
        activeColorSecondary: AppColors.background,
        activeForegroundColor: AppColors.background,
        inactiveBackgroundColor: AppColors.textSecondary,
        inactiveForegroundColor: AppColors.textSecondary,
      ),
    ),
    PersistentTabConfig.noScreen(
      item: ItemConfig(
        icon: Icon(Icons.qr_code_scanner_outlined),
        iconSize: 36,
        activeForegroundColor: AppColors.background,

        inactiveForegroundColor: AppColors.primary,
      ),
      onPressed: (p0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScanPage()),
        );
      },
    ),
    PersistentTabConfig(
      screen: RepairPage(),
      item: ItemConfig(
        icon: Icon(Icons.home_repair_service),
        title: 'Repair',
        iconSize: 32,
        activeColorSecondary: AppColors.background,
        activeForegroundColor: AppColors.background,
        inactiveBackgroundColor: AppColors.textSecondary,
        inactiveForegroundColor: AppColors.textSecondary,
      ),
    ),
    PersistentTabConfig(
      screen: LocatorPage(),
      item: ItemConfig(
        icon: Icon(Icons.map),
        title: 'Locator',
        iconSize: 32,
        activeColorSecondary: AppColors.background,
        activeForegroundColor: AppColors.background,
        inactiveBackgroundColor: AppColors.textSecondary,
        inactiveForegroundColor: AppColors.textSecondary,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) => PersistentTabView(
    navBarOverlap: NavBarOverlap.full(),
    tabs: _tabs(context),
    navBarBuilder: (navBarConfig) => Style13BottomNavBar(
      height: 70,
      middleItemSize: 74,
      navBarConfig: navBarConfig,
      navBarDecoration: NavBarDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
    ),
  );
}
