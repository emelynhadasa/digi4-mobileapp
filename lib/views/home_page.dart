import 'package:digi4_mobile/blocs/dashboard/dashboard_bloc.dart';
import 'package:digi4_mobile/models/dashboard_model.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';
import 'package:digi4_mobile/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!_hasLoaded) {
      _hasLoaded = true;
      context.read<DashboardBloc>().add(DashboardRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          // Navigasi ke login setelah logout berhasil
          Navigator.of(context).pushReplacementNamed('/login');
        } else if (state is LoginFailure) {
          // Tampilkan pesan error jika logout gagal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(DashboardReloadRequested());
            },
            child: SafeArea(child: _buildContent(context, state)),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardState state) {
    // Loading state
    if (state is DashboardLoading) {
      return _buildLoadingState();
    }
    // Error state
    else if (state is DashboardFailure) {
      return _buildErrorState(state.message);
    }
    // Success state with data
    else if (state is DashboardSuccess) {
      return _buildDashboardContent(context, state.dashboardModel);
    }

    // Initial or unknown state
    return _buildDefaultContent(context);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text('Loading dashboard data...', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Unable to load dashboard',
                style: AppTextStyles.h3.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<DashboardBloc>().add(DashboardReloadRequested());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Retry', style: AppTextStyles.buttonLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PERBAIKAN: Enhanced dashboard content with proper repair request data processing
  Widget _buildDashboardContent(BuildContext context,
      DashboardModel dashboard,) {
    print('=== BUILDING DASHBOARD CONTENT ===');
    print('Recent Reusables: ${dashboard.recentReusables}');

    // Convert dashboard data to format expected by the existing UI components
    List<Map<String, dynamic>> cards = [
      {
        'svgPath': 'assets/asset.svg',
        'count': '${dashboard.totalAssets}',
        'label': 'Assets',
      },
      {
        'svgPath': 'assets/instance.svg',
        'count': '${dashboard.totalInstances}',
        'label': 'Instances',
      },
      {
        'svgPath': 'assets/repair.svg',
        'count': '${dashboard.openRepairCount}',
        'label': 'Repairs in Progress',
      },
      {
        'svgPath': 'assets/purchase.svg',
        'count': '${dashboard.ongoingPurchaseCount}',
        'label': 'Purchases in Progress',
      },
    ];

    String formatDate(String isoDateString) {
      try {
        DateTime parsedDate = DateTime.parse(isoDateString);
        return DateFormat('d MMM yyyy HH:mm').format(
            parsedDate); // Contoh: 20 May 2025 18:24
      } catch (e) {
        return 'Invalid date';
      }
    }

    // PERBAIKAN: Process recent consumables
    List<Map<String, dynamic>> consumables = [];
    for (var item in dashboard.recentConsumables) {
      print('Processing consumable: $item');

      if (item is Map<String, dynamic>) {
        String rawDate = item['Date'] ?? item['date'] ?? '';
        String formattedDate = formatDate(rawDate);
        consumables.add({
          'name': item['AssetName'] ?? item['name'] ?? 'Unnamed Consumable',
          'date': formattedDate ?? "No date",
          'description': item['Remarks'] ?? 'No description available',
        });
      } else {
        print('Unexpected consumable format: ${item.runtimeType}');
      }
    }

    List<Map<String, dynamic>> reusables = [];
    for (var item in dashboard.recentReusables) {
      print('Processing reusable: $item');

      if (item is Map<String, dynamic>) {
        String rawDate = item['Date'] ?? item['date'] ?? '';
        String formattedDate = formatDate(rawDate);
        reusables.add({
          'name': item['AssetName'] ?? item['name'] ?? 'Unnamed Consumable',
          'date': formattedDate ?? "No date",
          'description': item['Details'] ?? 'No description available',
        });
      } else {
        print('Unexpected consumable format: ${item.runtimeType}');
      }
    }

    // PERBAIKAN: Provide meaningful empty states
    if (consumables.isEmpty) {
      consumables = [
        {
          'name': 'No Recent Consumable Transactions',
          'date': '',
          'description':
          'There are no recent consumable transactions to display',
        },
      ];
    }

    if (reusables.isEmpty) {
      reusables = [
        {
          'name': 'No Recent Reusable Transactions',
          'date': '',
          'status': 'None',
          'description': 'There are no recent reusable transactions to display',
          'type': 'empty',
        },
      ];
    }

    print('Final reusables count: ${reusables.length}');

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back', style: AppTextStyles.bodySmall),
                    Text(dashboard.userName, style: AppTextStyles.h2),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    print("Logout event fired");
                    context.read<AuthBloc>().add(
                      AuthLogoutRequested(context: context),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/logout.svg',
                    height: 35, // Atur sesuai kebutuhan
                    width: 35,
                  ),
                ),
              ],
            ),
          ),

          // Cards Grid
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildCard(cards[0]),
                    const SizedBox(width: 8),
                    _buildCard(cards[1]),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCard(cards[2]),
                    const SizedBox(width: 8),
                    _buildCard(cards[3]),
                  ],
                ),
              ],
            ),
          ),

          // Low Stock Section (if available)
          // ===== Low Stock Items Block =====
          if (dashboard.lowStock.isNotEmpty)
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05), // abu-abu sheer untuk blok
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      'Low Stock Items',
                      'assets/low-stock.svg',
                      bgColor: Colors.transparent,     // karena blok luar sudah punya latar
                      textColor: Colors.black87,
                      topPadding: 0,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppColors.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${dashboard.lowStock.length} items are running low on stock',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ===== Expiring Warranties Block =====
          if (dashboard.expiringWarranties.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05), // abu-abu sheer untuk blok
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      'Expiring Warranties',
                      'assets/warranty-expiring.svg',
                      bgColor: Colors.transparent,
                      textColor: Colors.black87,
                      topPadding: 0,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${dashboard.expiringWarranties.length} warranties are expiring soon',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ===== Recent Transactions (Consumable + Reusable) =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),

                // Consumable Transactions Block
                _buildSectionTitle(
                  'Recent Consumable Transactions',
                  'assets/transaction.svg',
                  bgColor: Colors.grey.withOpacity(0.1),
                  textColor: Colors.black87,
                  topPadding: 0,
                ),
                ..._buildConsumableList(context, consumables),

                const SizedBox(height: 14),

                // Reusable Transactions Block
                _buildSectionTitle(
                  'Recent Reusable Transactions',
                  'assets/transaction.svg',
                  bgColor: Colors.grey.withOpacity(0.1),
                  textColor: Colors.black87,
                  topPadding: 0,
                ),
                ..._buildReusableList(context, reusables),
              ],
            ),
          ),
          // Add some bottom padding for better scrolling experience
          SizedBox(height: 24),
        ],
      ),
    );
  }

  // For initial state or fallback
  Widget _buildDefaultContent(BuildContext context) {
    // Use placeholder data until real data loads
    final List<Map<String, dynamic>> cards = [
      {'icon': Icons.assessment, 'count': '-', 'label': 'Assets'},
      {'icon': Icons.storage, 'count': '-', 'label': 'Instances'},
      {'icon': Icons.build, 'count': '-', 'label': 'Repairs in Progress'},
      {
        'icon': Icons.shopping_cart,
        'count': '-',
        'label': 'Purchases in Progress',
      },
    ];

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back', style: AppTextStyles.bodySmall),
                    Text('Loading...', style: AppTextStyles.h2),
                  ],
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: AppColors.primary),
                ),
              ],
            ),
          ),

          // Cards Grid with placeholder data
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildCard(cards[0]),
                    const SizedBox(width: 8),
                    _buildCard(cards[1]),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCard(cards[2]),
                    const SizedBox(width: 8),
                    _buildCard(cards[3]),
                  ],
                ),
              ],
            ),
          ),

          // Loading indicator for the rest of the content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> card) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // ⬅️ Biar teks/ikon gak mentok
        margin: const EdgeInsets.symmetric(horizontal: 6),
        height: 140, // ⬆️ Tinggikan box
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // ⬅️ Biar antar elemen lebih merata
          children: [
            // Ikon SVG atau biasa
            if (card.containsKey('svgPath'))
              SvgPicture.asset(
                card['svgPath'],
                height: 40,  // ⬆️ Sedikit lebih besar
                width: 40,
              )
            else
              Icon(
                card['icon'],
                size: 40,
                color: AppColors.primary,
              ),

            // Jumlah
            Text(
              card['count'],
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            // Label
            Text(
              card['label'],
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[700],
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      String iconPath, {
        Color bgColor = const Color(0xFFE0E0E0),  // default abu‐abu sheer
        Color iconColor = Colors.black54,         // default warna ikon
        Color textColor = Colors.black87,         // default warna teks
        double topPadding = 0,                    // ⬅️ kontrol jarak atas
      }) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              height: 26,
              width: 26,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.h4.copyWith(
                color: textColor,
                height: 1.2,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConsumableList(BuildContext context,
      List<Map<String, dynamic>> consumables,) {
    return consumables.map((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? 'Unknown Item', style: AppTextStyles.h4),
                const SizedBox(height: 6),
                if (item['date'] != null && item['date'].isNotEmpty)
                  Text(item['date'], style: AppTextStyles.caption),
                const SizedBox(height: 8),
                Text(
                  item['description'] ?? 'No description available',
                  style: AppTextStyles.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildReusableList(BuildContext context,
      List<Map<String, dynamic>> reusables,) {
    return reusables.map((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? 'Unknown Item', style: AppTextStyles.h4),
                const SizedBox(height: 6),
                if (item['date'] != null && item['date'].isNotEmpty)
                  Text(item['date'], style: AppTextStyles.caption),
                const SizedBox(height: 8),
                Text(
                  item['description'] ?? 'No description available',
                  style: AppTextStyles.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

