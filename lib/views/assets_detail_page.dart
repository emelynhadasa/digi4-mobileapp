import 'package:digi4_mobile/blocs/asset/assets_bloc.dart';
import 'package:digi4_mobile/models/assets_model.dart';
import 'package:digi4_mobile/routes.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:digi4_mobile/views/instances_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digi4_mobile/config/constant.dart';

class AssetDetailPage extends StatefulWidget {
  // Membuat assetId opsional
  final int? assetId;
  final AssetsModel?
  asset; // Menambahkan parameter untuk menerima objek asset langsung

  // Constructor dengan parameter opsional
  const AssetDetailPage({super.key, this.assetId, this.asset});

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  // Data default jika loading atau error
  final Map<String, dynamic> defaultAsset = {
    'id': 'AST-2301-001',
    'name': 'Impact Wrench 1/2"',
    'image': 'https://example.com/tool1.jpg',
    'brand': 'Ingersoll Rand',
    'specs': 'Torque: 650 Nm\nWeight: 3.2 kg\nPower: 600W\nSN: IW-2301-65',
    'createdAt': '2023-01-15',
    'type': 'Reusable',
  };

  bool _isLoadingFromId = false;

  @override
  void initState() {
    super.initState();
    // Cek jika assetId diberikan dan asset tidak diberikan
    if (widget.assetId != null && widget.asset == null) {
      _isLoadingFromId = true;
      // Load asset dari API menggunakan ID
      context.read<AssetsBloc>().add(
        AssetsLoadByIdRequested(assetId: widget.assetId!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssetsBloc, AssetsState>(
      listener: (context, state) {
        // Jika ada update success, reload data detail
        if (state is AssetsUpdatedSuccess) {
          final id = widget.assetId ?? widget.asset?.assetId;
          if (id != null) {
            context.read<AssetsBloc>().add(
              AssetsLoadByIdRequested(assetId: id),
            );
          }
        }

        // Handle delete success
        if (state is AssetsDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Asset deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        }

        // Handle delete failure
        if (state is AssetsDeleteFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete asset: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Asset Details',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _isLoadingFromId ? _buildBlocContent() : _buildContentWithAsset(),
      ),
    );
  }

  // Widget untuk menampilkan content dengan BLoC (ketika assetId diberikan)
  Widget _buildBlocContent() {
    return BlocBuilder<AssetsBloc, AssetsState>(
      builder: (context, state) {
        if (state is AssetsLoadByIdLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Loading asset details...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        } else if (state is AssetsLoadByIdFailure) {
          return _buildErrorView(state.message);
        } else if (state is AssetsLoadByIdSuccess) {
          // Konversi AssetsModel ke format yang dibutuhkan UI
          final assetData = _convertAssetModelToMap(state.asset);
          return _buildDetailView(context, assetData);
        } else {
          // Default state, gunakan data default
          return _buildDetailView(context, defaultAsset);
        }
      },
    );
  }

  // Widget untuk menampilkan content langsung (ketika asset objek langsung diberikan atau default)
  Widget _buildContentWithAsset() {
    if (widget.asset != null) {
      // Konversi AssetsModel ke format yang dibutuhkan UI
      final assetData = _convertAssetModelToMap(widget.asset!);
      return _buildDetailView(context, assetData);
    } else {
      // Gunakan data default
      return _buildDetailView(context, defaultAsset);
    }
  }

  // PERBAIKAN: Helper untuk mengkonversi AssetsModel ke format yang digunakan UI
  Map<String, dynamic> _convertAssetModelToMap(AssetsModel asset) {
    print('=== CONVERT ASSET MODEL DEBUG ===');
    print('Asset ID: ${asset.assetId}');
    print('Asset Name: ${asset.assetName}');
    print('Asset Brand: ${asset.brand}');
    print('Asset Category ID: ${asset.assetCategoryId}');
    print('====================================');

    final convertedData = {
      'id': asset.assetId.toString() ?? 'Unknown',
      'name': asset.assetName ?? 'Unknown Asset',
      'image': asset.imageFileName.isNotEmpty
          ? '${Constant.baseImageUrl}/AssetImg/${asset.imageFileName}'
          : 'https://example.com/placeholder.jpg',
      'brand': asset.brand ?? 'Unknown Brand',
      'specs': asset.specs ?? 'No specifications available',
      'createdAt': asset.createdAt.toString().split('T')[0] ?? 'Unknown Date',
      'type': asset.assetCategoryId == 1 ? 'Consumable' : 'Reusable',
      // PERBAIKAN: Tambahan data untuk debugging
      'assetId': asset.assetId,
      'assetName': asset.assetName,
    };

    print('Converted data: $convertedData');
    return convertedData;
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 64,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Failed to load asset details',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              errorMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (widget.assetId != null) {
                      context.read<AssetsBloc>().add(
                        AssetsLoadByIdRequested(assetId: widget.assetId!),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: Icon(Icons.refresh),
                  label: Text('Retry'),
                ),
                SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: Icon(Icons.arrow_back),
                  label: Text('Go Back'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, Map<String, dynamic> asset) {
    // PERBAIKAN: Debug asset data sebelum digunakan
    print('=== DETAIL VIEW ASSET DATA ===');
    print('Asset data: $asset');
    print('===============================');

    return RefreshIndicator(
      onRefresh: () async {
        final id = widget.assetId ?? widget.asset?.assetId;
        if (id != null) {
          context.read<AssetsBloc>().add(AssetsLoadByIdRequested(assetId: id));
        }
        await Future.delayed(Duration(milliseconds: 500));
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  asset['image'],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppColors.primary,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.inventory,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            // Asset Information
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Asset Information',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  _buildDetailRow('Asset ID', asset['id']),
                  _buildDetailRow('Name', asset['name']),
                  _buildDetailRow('Brand', asset['brand']),
                  _buildDetailRow('Type', asset['type']),
                  _buildDetailRow('Created At', asset['createdAt'].toString()),
                  SizedBox(height: 16),
                  Text(
                    'Specifications:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Text(
                      asset['specs'],
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Edit',
                    AppColors.primary,
                    Icons.edit_outlined,
                        () {
                      final id = widget.assetId ?? (widget.asset?.assetId);
                      if (id != null) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.editAsset,
                          arguments: id,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Cannot edit demo asset')),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Delete',
                    AppColors.error,
                    Icons.delete_outline,
                        () {
                      _showDeleteConfirmation(context);
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Instances',
                    AppColors.primary,
                    Icons.view_list_outlined,
                        () {
                      final id = widget.assetId ?? (widget.asset?.assetId);
                      final name = asset['name'] ?? asset['assetName'] ?? 'Unknown Asset';
                      final categoryId = asset['assetCategoryId'] ?? widget.asset?.assetCategoryId ?? 0;

                      if (id != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: context.read<AssetsBloc>(),
                              child: InstancesPage(
                                assetId: id.toString(),
                                assetName: name,
                                assetCategoryId: categoryId,
                              ),
                            ),
                          ),
                        );
                      } else {
                        final fallbackId = asset['id'];
                        if (fallbackId != null && fallbackId != 'Unknown') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<AssetsBloc>(),
                                child: InstancesPage(
                                  assetId: fallbackId.toString(),
                                  assetName: name,
                                ),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No instances available for demo asset'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showRepurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.request_quote_outlined, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Request Repurchase'),
          ],
        ),
        content: Text('Do you want to request a repurchase for this asset?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Repurchase request submitted'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Asset'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this asset?'),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Warning: This action cannot be undone!',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementasi delete asset
              final id = widget.assetId ?? (widget.asset?.assetId);
              if (id != null) {
                context.read<AssetsBloc>().add(
                  AssetDeleteRequested(assetId: id),
                );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$title:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text),
    );
  }
}
