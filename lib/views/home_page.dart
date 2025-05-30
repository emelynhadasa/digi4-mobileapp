import 'package:digi4_mobile/blocs/dashboard/dashboard_bloc.dart';
import 'package:digi4_mobile/models/dashboard_model.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when page is initialized
    context.read<DashboardBloc>().add(DashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: () async {
              // Reload dashboard data on pull-to-refresh
              context.read<DashboardBloc>().add(DashboardReloadRequested());
            },
            child: SafeArea(child: _buildContent(context, state)),
          ),
        );
      },
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
        'icon': Icons.assessment,
        'count': '${dashboard.totalAssets}',
        'label': 'Assets',
      },
      {
        'icon': Icons.storage,
        'count': '${dashboard.totalInstances}',
        'label': 'Instances',
      },
      {
        'icon': Icons.build,
        'count': '${dashboard.openRepairCount}',
        'label': 'Repairs in Progress',
      },
      {
        'icon': Icons.shopping_cart,
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
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: AppColors.primary),
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
          if (dashboard.lowStock.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Low Stock Items'),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${dashboard.lowStock
                                .length} items are running low on stock',
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

          // Expiring Warranties Section (if available)
          if (dashboard.expiringWarranties.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Expiring Warranties'),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: AppColors.warning),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${dashboard.expiringWarranties
                                .length} warranties are expiring soon',
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

          // Recent Transactions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                _buildSectionTitle('Recent Consumable Transaction'),
                ..._buildConsumableList(context, consumables),
                const SizedBox(height: 14),
                _buildSectionTitle('Recent Reusable Transaction',),
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
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(card['icon'], size: 34, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(card['count'], style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                card['label'],
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Text(title, style: AppTextStyles.h4),
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

