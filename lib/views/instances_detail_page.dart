import 'package:digi4_mobile/blocs/asset/assets_bloc.dart';
import 'package:digi4_mobile/blocs/repair_request/repair_request_bloc.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:digi4_mobile/views/instances_ask_repair_page.dart';
import 'package:digi4_mobile/views/instances_checkin_page.dart';
import 'package:digi4_mobile/views/instances_checkout_page.dart';
import 'package:digi4_mobile/views/instances_edit_page.dart';
import 'package:digi4_mobile/views/instances_logs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InstancesDetailPage extends StatefulWidget {
  final Map<String, dynamic> instance;

  const InstancesDetailPage({super.key, required this.instance});

  @override
  State<InstancesDetailPage> createState() => _InstancesDetailPageState();
}

class _InstancesDetailPageState extends State<InstancesDetailPage> {
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Instance'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this instance?'),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Instance: ${widget.instance['instanceId'] ?? widget.instance['InstanceId'] ?? 'Unknown'}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Warning: This action cannot be undone!',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.warning,
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
              Navigator.pop(context); // Close dialog
              _handleDeleteInstance();
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

  void _showMarkFoundConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.find_in_page, color: AppColors.success),
            SizedBox(width: 8),
            Text('Mark as Found'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to mark this instance as found?'),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Instance: ${widget.instance['instanceId'] ?? widget.instance['InstanceId'] ?? 'Unknown'}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'This will change the status from Missing to Available.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.info,
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
              Navigator.pop(context); // Close dialog
              _handleMarkAsFound();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: Text('Mark as Found'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteInstance() {
    final instanceId = widget.instance['instanceId'];
    if (instanceId != null) {
      print('=== DELETING INSTANCE ===');
      print('Instance ID: $instanceId');

      context.read<AssetsBloc>().add(
        AssetInstanceDeleteRequested(
          instanceId: int.parse(instanceId.toString()),
        ),
      );
    } else {
      _showErrorSnackBar('Instance ID not found');
    }
  }

  void _handleMarkAsFound() {
    final instanceId = widget.instance['InstanceId'] ?? widget.instance['instanceId'];
    if (instanceId != null) {
      print('=== MARKING INSTANCE AS FOUND ===');
      print('Instance ID: $instanceId');

      context.read<AssetsBloc>().add(
        InstanceMarkFoundRequested(
          instanceId: int.parse(instanceId.toString()),
        ),
      );
    } else {
      _showErrorSnackBar('Instance ID not found');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssetsBloc, AssetsState>(
      listener: (context, state) {
        if (state is AssetsUpdatedSuccess ||
            state is ChekcoutInstanceSuccess ||
            state is CheckinInstanceSuccess ||
            state is AssetsMarkFoundSuccess) {
          final message = state is AssetsUpdatedSuccess
              ? state.message
              : state is ChekcoutInstanceSuccess
              ? state.message
              : state is CheckinInstanceSuccess
              ? state.message
              : (state as AssetsMarkFoundSuccess).message;

          _showSuccessSnackBar(message);

          // Navigate back to instances list for delete operations
          if (state is AssetsUpdatedSuccess &&
              state.message.contains('deleted')) {
            Navigator.of(context).pop();
          }
        } else if (state is AssetsLoadByIdFailure) {
          _showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Instance Details',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
              onSelected: (String value) {
                switch (value) {
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<AssetsBloc>(),
                          child: InstanceEditPage(instance: widget.instance),
                        ),
                      ),
                    );
                    break;
                  case 'delete':
                    _showDeleteConfirmation();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<AssetsBloc, AssetsState>(
          builder: (context, state) {
            final isLoading =
                state is AssetsLoadByIdLoading ||
                state is ChekcoutInstanceLoading ||
                state is CheckinInstanceLoading ||
                state is AssetsMarkFoundLoading;

            if (isLoading) {
              String loadingMessage = 'Processing...';
              if (state is AssetsLoadByIdLoading) {
                loadingMessage = state.message ?? 'Processing...';
              } else if (state is ChekcoutInstanceLoading) {
                loadingMessage = state.message ?? 'Processing checkout...';
              } else if (state is CheckinInstanceLoading) {
                loadingMessage = state.message ?? 'Processing check-in...';
              } else if (state is AssetsMarkFoundLoading) {
                loadingMessage = state.message ?? 'Marking as found...';
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(loadingMessage, style: AppTextStyles.bodyMedium),
                  ],
                ),
              );
            }

            return _buildDetailView(context, widget.instance);
          },
        ),
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, Map<String, dynamic> instance) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner - Show current status prominently
          _buildStatusBanner(instance),
          SizedBox(height: 20),

          // QR Code Section
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.network(
                  instance['qrCodeUrl'] ?? instance['QrCodeUrl'] ?? '',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Detail Information
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
                    Text('General Information', style: AppTextStyles.h4),
                  ],
                ),
                Divider(height: 24),
                _buildDetailRow(
                  'Instance ID',
                  instance['instanceId']?.toString() ??
                      instance['InstanceId']?.toString() ??
                      instance['instanceID']?.toString(),
                ),
                _buildDetailRow(
                  'Asset ID',
                  instance['assetId']?.toString() ??
                      instance['AssetId']?.toString() ??
                      instance['assetID']?.toString(),
                ),
                _buildDetailRow(
                  'Asset Name',
                  instance['assetName'] ?? instance['AssetName'],
                ),
                _buildDetailRow(
                  'Type',
                  instance['type'] ?? instance['Type'],
                ),
                _buildDetailRow(
                  'Status',
                  instance['status'] ?? instance['Status'],
                ),
                _buildDetailRow(
                  'Condition',
                  instance['condition'] ?? instance['Condition'],
                ),
                _buildDetailRow(
                  'Location',
                  instance['location'] ?? instance['Location'],
                ),
                _buildDetailRow(
                  'Plant',
                  instance['plant'] ?? instance['Plant'],
                ),
                _buildDetailRow(
                  'Shelf',
                  instance['shelf'] ?? instance['Shelf'],
                ),
                _buildDetailRow(
                  'Serial Number',
                  instance['serialNumber'] ?? instance['SerialNumber'],
                ),
                _buildDetailRow(
                  'Warranty Expiry',
                  instance['warrantyExpiryDate'] ?? instance['WarrantyExpiryDate'],
                ),
                if (instance['qty'] != null || instance['Qty'] != null)
                  _buildDetailRow(
                    'Quantity',
                    instance['qty']?.toString() ?? instance['Qty']?.toString(),
                  ),
                if (instance['restockThreshold'] != null || instance['RestockThreshold'] != null)
                  _buildDetailRow(
                    'Restock Threshold',
                    instance['restockThreshold']?.toString() ??
                        instance['RestockThreshold']?.toString(),
                  ),
                if (instance['shelfLife'] != null || instance['ShelfLife'] != null)
                  _buildDetailRow(
                    'Shelf Life',
                    instance['shelfLife']?.toString() ?? instance['ShelfLife']?.toString(),
                  ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // General Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Edit',
                  AppColors.primary,
                  Icons.edit_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<AssetsBloc>(),
                          child: InstanceEditPage(instance: instance),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Delete',
                  AppColors.error,
                  Icons.delete_outlined,
                  () {
                    _showDeleteConfirmation();
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'See Logs',
                  AppColors.info,
                  Icons.history_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InstanceLogsPage(
                          instanceId: instance['instanceId'] ?? instance['InstanceId'],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Transaction Section
          Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'Transactions',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          _buildConditionalActionButtons(instance),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(Map<String, dynamic> instance) {
    final String status = instance['status'] ?? instance['Status'] ?? '';
    final String condition = instance['condition'] ?? instance['Condition'] ?? '';

    Color bannerColor;
    IconData bannerIcon;
    String bannerText;

    // Determine banner style based on status and condition
    if (status == 'Missing') {
      bannerColor = AppColors.error;
      bannerIcon = Icons.error_outline;
      bannerText = 'This item is currently MISSING';
    } else if (status == 'In Use') {
      bannerColor = AppColors.warning;
      bannerIcon = Icons.access_time;
      bannerText = 'This item is currently IN USE';
    } else if (condition == 'Damaged') {
      bannerColor = AppColors.warning;
      bannerIcon = Icons.build_outlined;
      bannerText = 'This item needs REPAIR';
    } else {
      bannerColor = AppColors.success;
      bannerIcon = Icons.check_circle_outline;
      bannerText = 'This item is AVAILABLE for use';
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(bannerIcon, color: bannerColor, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bannerText,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: bannerColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Status: $status | Condition: $condition',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: bannerColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionalActionButtons(Map<String, dynamic> instance) {
    final String type = instance['type'] ?? instance['Type'] ?? '';
    final String status = instance['status'] ?? instance['Status'] ?? '';
    final String condition = instance['condition'] ?? instance['Condition'] ?? '';

    print('=== BUILDING ACTION BUTTONS ===');
    print('Type: $type');
    print('Status: $status');
    print('Condition: $condition');

    // Case 1: Missing items - Show Mark as Found button
    if (status == 'Missing') {
      return Center(
        child: _buildActionButton(
          'Mark as Found',
          AppColors.success,
          Icons.find_in_page,
          () {
            print('Mark as Found tapped');
            _showMarkFoundConfirmation();
          },
        ),
      );
    }

    // Case 2: Consumable items - Show Checkout only
    if (type == 'Consumable') {
      return Center(
        child: _buildActionButton(
          'Checkout',
          AppColors.success,
          Icons.shopping_cart_checkout,
          () {
            print('Checkout (Consumable) tapped');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<AssetsBloc>(),
                  child: InstanceCheckoutPage(instance: instance),
                ),
              ),
            );
          },
        ),
      );
    }

    // Case 3: Reusable items - Show appropriate buttons based on status
    if (type == 'Reusable') {
      bool canCheckout = false;
      bool canCheckin = false;
      bool canAskRepair = false;

      // Apply business rules
      if (status == 'Available') {
        canCheckout = true;
        if (condition == 'Damaged') {
          canAskRepair = true;
        }
      } else if (status == 'In Use') {
        canCheckin = true;
      }

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Checkout',
                  AppColors.success,
                  Icons.arrow_upward_outlined,
                  canCheckout
                      ? () {
                          print('Checkout (Reusable) tapped');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<AssetsBloc>(),
                                child: InstanceCheckoutPage(instance: instance),
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Check-in',
                  AppColors.info,
                  Icons.arrow_downward_outlined,
                  canCheckin
                      ? () {
                          print('Check-in (Reusable) tapped');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<AssetsBloc>(),
                                child: InstanceCheckinPage(instance: instance),
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Ask for Repair',
                  AppColors.warning,
                  Icons.build_outlined,
                  canAskRepair
                      ? () {
                          print('Ask for Repair tapped');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<RepairRequestBloc>(),
                                child: InstanceAskRepairPage(
                                  instance: instance,
                                ),
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(': ', style: TextStyle(color: AppColors.textSecondary)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              (value?.isNotEmpty == true) ? value! : '-',
              style: AppTextStyles.bodyMedium.copyWith(
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
    VoidCallback? onPressed,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withOpacity(0.4),
        disabledForegroundColor: Colors.white.withOpacity(0.7),
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTextStyles.bodyMedium,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text),
    );
  }
}
