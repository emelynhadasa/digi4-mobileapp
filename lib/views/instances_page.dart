
import 'package:digi4_mobile/routes.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:digi4_mobile/views/instances_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digi4_mobile/blocs/asset/assets_bloc.dart';
import 'package:digi4_mobile/models/assets_model.dart';

class InstancesPage extends StatefulWidget {
  final String? assetId;
  final String? assetName;

  const InstancesPage({super.key, this.assetId, this.assetName});

  @override
  _InstancesPageState createState() => _InstancesPageState();
}

class _InstancesPageState extends State<InstancesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        _hasInitialized = true;
        _loadAssetInstances();
      }
    });
  }

  void _loadAssetInstances() {
    try {
      // PERBAIKAN: Better parameter handling
      String? assetId = widget.assetId;
      String assetName = widget.assetName ?? 'Unknown Asset';

      // Fallback ke route arguments jika widget parameters kosong
      if (assetName == 'Unknown Asset') {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

        if (args != null) {
          if (assetId == null && args['assetId'] != null) {
            assetId = args['assetId'].toString();
          }

          if (assetName == 'Unknown Asset' && args['assetName'] != null) {
            assetName = args['assetName'].toString();
          }
        }
      }

      if (assetId != null && assetId.isNotEmpty) {
        final parsedAssetId = int.tryParse(assetId);
        if (parsedAssetId != null) {
          // PERBAIKAN: Gunakan event yang benar sesuai dengan BLoC yang ada
          context.read<AssetsBloc>().add(
            AssetInstanceLoaded(assetId: parsedAssetId),
          );
        } else {
          print('❌ Invalid asset ID format: $assetId');
        }
      } else {
        print('❌ No asset ID provided');
      }
    } catch (e) {
      print('❌ Error loading asset instances: $e');
    }
  }

  // Convert AssetInstances model to Map for UI compatibility
  List<Map<String, dynamic>> _convertAssetsToMap(
    List<AssetInstances> instances,
  ) {
    return instances.map((instance) {
      return {
        'instanceId': instance.instanceId.toString() ?? 'Unknown',
        'assetId': instance.assetId.toString() ?? 'Unknown',
        'qrCodeId': instance.qrCodeId.toString() ?? 'Unknown',
        'qrCodeUrl': instance.encodedData != null
            ? 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${instance.encodedData}'
            : '',
        'encodedData': instance.encodedData ?? '',
        'qrCodeImageBase64': instance.qrCodeImageBase64,
        'location': instance.location ?? 'Unknown Location',
        'type': _getAssetTypeFromInstance(instance),
        'status': instance.status ?? 'Unknown',
        'condition': instance.condition ?? 'Unknown',
        'warrantyExpiryDate': _formatDate(instance.warrantyExpiryDate),
        'lifetime': instance.lifetime != null
            ? '${instance.lifetime} Years'
            : 'N/A',
        'serialNumber': instance.serialNumber ?? 'N/A',
        // 'qty': instance.quantity ?? 1,
        'plant': _extractPlantFromLocation(instance.location ?? ''),
        'shelf': instance.shelfId?.toString() ?? 'No Shelf',
        'shelfId': instance.shelfId,
        // 'restockThreshold': instance.restockThreshold ?? 1,
        // 'shelfLife': instance.shelfLife != null ? '${instance.shelfLife} days' : 'N/A',
        'assetName': _getAssetNameFromInstance(instance),
        'brand': _getBrandFromInstance(instance),
        'model': 'N/A',
        'lastCheckedOutByKpk': instance.lastCheckedOutByKpk,
        'hasBeenCheckedIn': instance.hasBeenCheckedIn ?? true,
        'checkedOutByName': instance.checkedOutByName,
        'lastCheckedOutDate': _formatDate(instance.lastCheckedOutDate),
        'repairRequestStatus': instance.repairRequestStatus,
        'repairRequestedByName': instance.repairRequestedByName,
      };
    }).toList();
  }

  // Helper methods untuk extract data dari nested asset object
  String _getAssetNameFromInstance(AssetInstances instance) {
    if (instance.asset != null) {
      if (instance.asset is Map) {
        return (instance.asset as Map)['AssetName']?.toString() ??
            'Unknown Asset';
      } else if (instance.asset is AssetsModel) {
        return (instance.asset as AssetsModel).assetName ?? 'Unknown Asset';
      }
    }
    return widget.assetName ?? 'Unknown Asset';
  }

  String _getBrandFromInstance(AssetInstances instance) {
    if (instance.asset != null) {
      if (instance.asset is Map) {
        return (instance.asset as Map)['Brand']?.toString() ?? 'Unknown Brand';
      } else if (instance.asset is AssetsModel) {
        return (instance.asset as AssetsModel).brand ?? 'Unknown Brand';
      }
    }
    return 'Unknown Brand';
  }

  String _getAssetTypeFromInstance(AssetInstances instance) {
    if (instance.asset != null) {
      if (instance.asset is Map) {
        final categoryId = (instance.asset as Map)['AssetCategoryId'];
        return categoryId == 1 ? 'Consumable' : 'Reusable';
      } else if (instance.asset is AssetsModel) {
        return (instance.asset as AssetsModel).assetCategoryId == 1
            ? 'Consumable'
            : 'Reusable';
      }
    }
    return 'Reusable';
  }

  String _extractPlantFromLocation(String location) {
    if (location.isEmpty) return 'Unknown Plant';

    final parts = location.split('-');
    if (parts.isNotEmpty) {
      return parts[0].trim();
    }
    return location;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<void> _onRefresh() async {
    _loadAssetInstances();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // PERBAIKAN: Improved parameter handling for display
    String assetName = 'Unknown Asset';
    String? assetId;

    // Prioritas: widget parameters > route arguments
    if (widget.assetName != null && widget.assetName!.isNotEmpty) {
      assetName = widget.assetName!;
    }

    if (widget.assetId != null && widget.assetId!.isNotEmpty) {
      assetId = widget.assetId!;
    }

    // Fallback ke route arguments jika widget parameters kosong
    if (assetName == 'Unknown Asset' || assetId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        if (assetName == 'Unknown Asset' && args['assetName'] != null) {
          assetName = args['assetName'].toString();
        }

        if (assetId == null && args['assetId'] != null) {
          assetId = args['assetId'].toString();
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instances',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              assetName,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: 'Refresh Instances',
            onPressed: () => _loadAssetInstances(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Info
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Asset: $assetName',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (assetId != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'ID: $assetId',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Create Instance Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          'Create',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.instancesCreate,
                            arguments: {
                              'assetId': assetId,
                              'assetName': assetName,
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  // PERBAIKAN: Instance count dengan BLoC integration yang benar
                  BlocBuilder<AssetsBloc, AssetsState>(
                    builder: (context, state) {
                      int totalCount = 0;
                      int availableCount = 0;
                      int inUseCount = 0;
                      int missingCount = 0;

                      if (state is AssetsInstancesLoaded) {
                        totalCount = state.instances.length;
                        for (var instance in state.instances) {
                          switch (instance.status.toString().toLowerCase()) {
                            case 'available':
                              availableCount++;
                              break;
                            case 'in use':
                            case 'checked out':
                              inUseCount++;
                              break;
                            case 'missing':
                              missingCount++;
                              break;
                          }
                        }
                      }

                      return Container(
                        margin: EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildCountCard(
                                'Total',
                                totalCount.toString(),
                                AppColors.primary,
                                Icons.inventory_2_outlined,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _buildCountCard(
                                'Available',
                                availableCount.toString(),
                                AppColors.success,
                                Icons.check_circle_outline,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _buildCountCard(
                                'In Use',
                                inUseCount.toString(),
                                AppColors.warning,
                                Icons.access_time,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _buildCountCard(
                                'Missing',
                                missingCount.toString(),
                                AppColors.error,
                                Icons.error_outline,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // PERBAIKAN: Instances List dengan BlocBuilder yang sesuai
            Expanded(
              child: BlocBuilder<AssetsBloc, AssetsState>(
                builder: (context, state) {
                  print('=== BLOC BUILDER DEBUG ===');
                  print('Current state: ${state.runtimeType}');

                  if (state is AssetsLoadByIdLoading) {
                    return _buildLoadingState();
                  } else if (state is AssetsLoadByIdFailure) {
                    return _buildErrorState(state.message);
                  } else if (state is AssetsInstancesLoaded) {
                    if (state.instances.isEmpty) {
                      return _buildEmptyState(assetId, assetName);
                    }
                    final convertedInstances = _convertAssetsToMap(
                      state.instances,
                    );
                    return _buildInstancesList(convertedInstances);
                  } else {
                    // Initial state
                    if (!_hasInitialized) {
                      return _buildLoadingState();
                    }
                    return _buildEmptyState(assetId, assetName);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 4),
          Text(
            count,
            style: AppTextStyles.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading instances...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
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
                size: 64,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Failed to Load Instances',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadAssetInstances(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String? assetId, String assetName) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Instances Found',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$assetName has no instances created yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Create your first instance to start tracking',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, size: 24),
              label: Text(
                'Create First Instance',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.instancesCreate,
                  arguments: {'assetId': assetId, 'assetName': assetName},
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstancesList(List<Map<String, dynamic>> instances) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: instances.length,
        itemBuilder: (context, index) {
          final instance = instances[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            child: _buildInstanceItem(instance),
          );
        },
      ),
    );
  }

  Widget _buildInstanceItem(Map<String, dynamic> instance) {
    final String status = instance['status']?.toString() ?? 'Unknown';
    final String condition = instance['condition']?.toString() ?? 'Unknown';
    final bool isCheckedOut =
        status.toLowerCase() == 'in use' ||
        status.toLowerCase() == 'checked out';
    final bool isMissing = status.toLowerCase() == 'missing';
    final bool hasRepairRequest = condition.toLowerCase() == 'damaged';

    // Status color and icon
    Color statusColor;
    IconData statusIcon;

    if (isMissing) {
      statusColor = AppColors.error;
      statusIcon = Icons.error_outline;
    } else if (isCheckedOut) {
      statusColor = AppColors.warning;
      statusIcon = Icons.access_time;
    } else if (hasRepairRequest) {
      statusColor = AppColors.warning;
      statusIcon = Icons.build_outlined;
    } else {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_outline;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCheckedOut || isMissing
              ? statusColor.withOpacity(0.3)
              : Colors.transparent,
          width: isCheckedOut || isMissing || hasRepairRequest ? 1.5 : 0,
        ),
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<AssetsBloc>(),
                  child: InstancesDetailPage(instance: instance),
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // QR Code Image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          instance['qrCodeUrl'] ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),

                    // Instance Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Instance ${instance['instanceId'] ?? 'N/A'}',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      statusIcon,
                                      size: 12,
                                      color: statusColor,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      status,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          if (instance['assetName'] != null) ...[
                            Text(
                              instance['assetName'].toString(),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                          ],
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${instance['plant'] ?? 'Unknown'} • ${instance['location'] ?? 'Unknown'}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrow Icon
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),

                // Additional Info Row
                if (instance['serialNumber'] != null ||
                    instance['condition'] != null) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        if (instance['serialNumber'] != null) ...[
                          Icon(
                            Icons.tag,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'SN: ${instance['serialNumber']}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        if (instance['serialNumber'] != null &&
                            instance['condition'] != null) ...[
                          SizedBox(width: 12),
                          Container(
                            width: 1,
                            height: 14,
                            color: AppColors.border,
                          ),
                          SizedBox(width: 12),
                        ],
                        if (instance['condition'] != null) ...[
                          Icon(
                            Icons.health_and_safety_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Condition: ${instance['condition']}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // PERBAIKAN: Repair request indicator seperti di kode asli
                if (hasRepairRequest) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 10,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'REPAIR',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
