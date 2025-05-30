import 'package:digi4_mobile/blocs/asset/assets_bloc.dart';
import 'package:digi4_mobile/models/assets_model.dart';
import 'package:digi4_mobile/routes.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';
import 'package:digi4_mobile/config/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  _AssetsPageState createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  // PERBAIKAN: Remove AutomaticKeepAliveClientMixin to fix bottom navbar overlap
  // with AutomaticKeepAliveClientMixin {
  // @override
  // bool get wantKeepAlive => true;

  // PERBAIKAN: Add lifecycle tracking
  bool _isDisposed = false;
  AssetsBloc? _assetsBloc;

  // Data aset dummy untuk fallback
  final List<Map<String, dynamic>> dummyAssets = [
    // {
    //   'image': 'https://example.com/tool1.jpg',
    //   'name': 'Impact Wrench 1/2"',
    //   'specs': 'Torque: 650 Nm\nWeight: 3.2 kg\nSN: IW-2301-65',
    // },
    // {
    //   'image': 'https://example.com/tool2.jpg',
    //   'name': 'Drill Machine Pro',
    //   'specs': 'Power: 800W\nRPM: 0-2800\nSN: DM-2240-80',
    // },
  ];

  @override
  void initState() {
    super.initState();
    // Load assets saat pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _safeAddEvent(AssetsRequested());
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // PERBAIKAN: Save BLoC reference safely
    try {
      _assetsBloc = context.read<AssetsBloc>();
    } catch (e) {
      print('Error getting AssetsBloc: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // PERBAIKAN: Safe context usage helper
  bool get _isMounted => mounted && !_isDisposed;

  // PERBAIKAN: Safe BLoC event dispatcher
  void _safeAddEvent(AssetsEvent event) {
    if (_isMounted && _assetsBloc != null) {
      try {
        _assetsBloc!.add(event);
      } catch (e) {
        print('Error adding BLoC event: $e');
      }
    }
  }

  // PERBAIKAN: Safe refresh method
  Future<void> _onRefresh() async {
    if (!_isMounted) return;

    _safeAddEvent(AssetsRequested());
    // Tunggu sebentar untuk memberi feedback ke user
    await Future.delayed(Duration(milliseconds: 500));
  }

  // PERBAIKAN: Safe navigation method
  Future<void> _navigateToAssetDetail(dynamic asset) async {
    if (!_isMounted) return;

    try {
      final result = await Navigator.pushNamed(
        context,
        AppRoutes.detailAsset,
        arguments: asset,
      );

      // PERBAIKAN: Check if widget is still mounted before accessing BLoC
      if (_isMounted) {
        _safeAddEvent(AssetsRequested());
      }
    } catch (e) {
      print('Navigation error: $e');
      // Handle navigation errors gracefully
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to navigate: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // PERBAIKAN: Safe create asset navigation
  Future<void> _navigateToCreateAsset() async {
    if (!_isMounted) return;

    try {
      final result = await Navigator.pushNamed(context, AppRoutes.createAsset);

      // PERBAIKAN: Check if widget is still mounted before accessing BLoC
      if (_isMounted) {
        _safeAddEvent(AssetsRequested());
      }
    } catch (e) {
      print('Create asset navigation error: $e');
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to navigate to create asset: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // PERBAIKAN: Safe bulk operations navigation
  Future<void> _navigateToBulkOperations() async {
    if (!_isMounted) return;

    try {
      await Navigator.pushNamed(context, AppRoutes.assetBulk);

      // PERBAIKAN: Refresh data after returning from bulk operations
      if (_isMounted) {
        _safeAddEvent(AssetsRequested());
      }
    } catch (e) {
      print('Bulk operations navigation error: $e');
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to navigate to bulk operations: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Remove super.build(context) since we're not using AutomaticKeepAliveClientMixin
    // super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assets',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  )
                ],
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.buttonText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _navigateToCreateAsset,
                      icon: Icon(Icons.add, size: 20),
                      label: Text(
                        'New Asset',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.buttonText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _navigateToBulkOperations,
                      icon: Icon(Icons.multiple_stop, size: 20),
                      label: Text(
                        'Bulk Ops',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.buttonText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Assets List dengan RefreshIndicator
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: BlocBuilder<AssetsBloc, AssetsState>(
                  builder: (context, state) {
                    // Show loading indicator
                    if (state is AssetsLoading) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.primary,
                        backgroundColor: Colors.white,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Loading assets...',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    // Show error with reload functionality
                    else if (state is AssetsLoadFailure) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.primary,
                        backgroundColor: Colors.white,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: AppColors.error,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Failed to load assets',
                                      style: AppTextStyles.h4.copyWith(
                                        color: AppColors.error,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pull down to refresh or tap retry',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (state.message.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          state.message,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(color: AppColors.error),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.buttonText,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: () {
                                        _safeAddEvent(AssetsRequested());
                                      },
                                      icon: Icon(Icons.refresh, size: 20),
                                      label: Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    // Show assets list
                    else if (state is AssetsLoaded) {
                      final assets = state.assets;

                      if (assets.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: AppColors.primary,
                          backgroundColor: Colors.white,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 64,
                                        color: AppColors.textSecondary
                                            .withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No assets found',
                                        style: AppTextStyles.h4.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Start by creating your first asset',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          foregroundColor: AppColors.buttonText,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: _navigateToCreateAsset,
                                        icon: Icon(Icons.add, size: 20),
                                        label: Text('Create Asset'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.primary,
                        backgroundColor: Colors.white,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: assets.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final asset = assets[index];
                            return GestureDetector(
                              onTap: () => _navigateToAssetDetail(asset),
                              child: _buildAssetItem(asset, index),
                            );
                          },
                        ),
                      );
                    }

                    // Default/Initial state - tampilkan dummy data dengan refresh
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColors.primary,
                      backgroundColor: Colors.white,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: dummyAssets.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              if (_isMounted) {
                                try {
                                  await Navigator.pushNamed(
                                    context,
                                    AppRoutes.detailAsset,
                                  );

                                  if (_isMounted) {
                                    _safeAddEvent(AssetsRequested());
                                  }
                                } catch (e) {
                                  print('Dummy asset navigation error: $e');
                                }
                              }
                            },
                            child: _buildAssetItem(dummyAssets[index], index),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetItem(dynamic asset, int index) {
    // Handle both Map<String, dynamic> and AssetsModel
    String name = '';
    String specs = '';
    String imageUrl = '';
    String assetId = '';
    String brand = '';
    String category = '';

    if (asset is AssetsModel) {
      name = asset.assetName;
      specs = [
        if (asset.brand.isNotEmpty) 'Brand: ${asset.brand}',
        if (asset.specs.isNotEmpty) asset.specs,
      ].join('\n');
      //imageUrl = asset.imageFileName;
      imageUrl = asset.imageFileName.isNotEmpty
          ? '${Constant.baseImageUrl}/AssetImg/${asset.imageFileName}'
          : '';
      print('Final image URL: $imageUrl');
      assetId = asset.assetId.toString();
      brand = asset.brand;
      // category = asset.categoryName;
    } else if (asset is Map<String, dynamic>) {
      name = asset['name'] ?? 'Unnamed Asset';
      specs = asset['specs'] ?? '';
      imageUrl = asset['image'] ?? '';
      assetId = asset['id']?.toString() ?? '';
      brand = asset['brand'] ?? '';
      category = asset['category'] ?? '';
    }

    return Hero(
      tag: 'asset_${assetId}_$index',
      child: Container(
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToAssetDetail(asset),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _AssetCardContent(
                imageUrl: imageUrl,
                name: name,
                category: category,
                brand: brand,
                specs: specs,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssetCardContent extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String category;
  final String brand;
  final String specs;

  const _AssetCardContent({
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.brand,
    required this.specs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      constraints: const BoxConstraints(minHeight: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AssetImage(imageUrl: imageUrl),
          const SizedBox(width: 16),
          Expanded(child: _AssetInfo(name: name, category: category, brand: brand, specs: specs)),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AssetImage extends StatelessWidget {
  final String imageUrl;

  const _AssetImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      child: imageUrl.isNotEmpty
          ? Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return const Icon(Icons.broken_image);
        },
      )
          : const Center(child: Icon(Icons.inventory_2, color: Colors.white)),
    );
  }
}

class _AssetInfo extends StatelessWidget {
  final String name;
  final String category;
  final String brand;
  final String specs;

  const _AssetInfo({
    required this.name,
    required this.category,
    required this.brand,
    required this.specs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (category.isNotEmpty || brand.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            children: [
              if (category.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ),
              // You can add brand badge here if needed
            ],
          ),
          const SizedBox(height: 6),
        ],
        if (specs.isNotEmpty)
          Text(
            specs,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
