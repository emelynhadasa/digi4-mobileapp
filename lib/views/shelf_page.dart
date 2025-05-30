import 'package:digi4_mobile/views/shelf_add_page.dart';
import 'package:digi4_mobile/views/shelf_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digi4_mobile/blocs/locator/locator_bloc.dart';
import 'package:digi4_mobile/models/locator_model.dart';
import 'package:digi4_mobile/routes.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';

class ShelfPage extends StatefulWidget {
  final String? cabinetId;
  final String? cabinetName;

  const ShelfPage({super.key, this.cabinetId, this.cabinetName});

  @override
  _ShelfPageState createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage> {
  // Data dummy sebagai fallback jika API gagal
  final List<Map<String, dynamic>> fallbackShelves = [
    // {'shelfId': '1', 'shelfLabel': 'Shelf A', 'assetCount': 12},
    // {'shelfId': '2', 'shelfLabel': 'Shelf B', 'assetCount': 8},
    // {'shelfId': '3', 'shelfLabel': 'Shelf C', 'assetCount': 15},
    // {'shelfId': '4', 'shelfLabel': 'Shelf D', 'assetCount': 5},
    // {'shelfId': '5', 'shelfLabel': 'Shelf E', 'assetCount': 10},
  ];

  @override
  void initState() {
    super.initState();
    // Load shelves saat halaman dibuka
    if (widget.cabinetId != null) {
      context.read<LocatorBloc>().add(GetShelves(cabinetId: widget.cabinetId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Shelves in ${widget.cabinetName ?? 'Cabinet'}',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Add Shelf Icon Button
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primary),
            tooltip: 'Add New Shelf',
            onPressed: () async {
              if (widget.cabinetId != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<LocatorBloc>(),
                      child: ShelfAddPage(
                        cabinetId: widget.cabinetId!,
                        cabinetName: widget.cabinetName,
                      ),
                    ),
                  ),
                );

                // Refresh shelves if shelf was added
                if (result == true) {
                  context.read<LocatorBloc>().add(
                    GetShelves(cabinetId: widget.cabinetId!),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Cabinet ID not available'),
                      ],
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {
              if (widget.cabinetId != null) {
                context.read<LocatorBloc>().add(
                  GetShelves(cabinetId: widget.cabinetId!),
                );
              }
            },
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
              child: Row(
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
                          'Cabinet: ${widget.cabinetName ?? 'Unknown'}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${widget.cabinetId ?? 'Unknown'}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Shelf List dengan BlocBuilder
            Expanded(
              child: BlocBuilder<LocatorBloc, LocatorState>(
                builder: (context, state) {
                  // Loading state
                  if (state is GetShelvesLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text(
                            'Loading shelves...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  // Success state - convert Shelf to Map format
                  else if (state is GetShelvesSuccess) {
                    final shelvesData = state.shelves
                        .map(
                          (shelf) => {
                            'shelfId': shelf.shelfId.toString(),
                            'shelfLabel': shelf.shelfLabel,
                            'assetCount':
                                0, // Default value jika tidak ada di model
                          },
                        )
                        .toList();

                    if (shelvesData.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildShelvesList(shelvesData);
                  }
                  // Error state - gunakan data fallback
                  else if (state is GetShelvesFailure) {
                    return Column(
                      children: [
                        // Error message
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_outlined,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Using offline data - ${state.error}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.refresh,
                                  color: AppColors.error,
                                ),
                                onPressed: () {
                                  if (widget.cabinetId != null) {
                                    context.read<LocatorBloc>().add(
                                      GetShelves(cabinetId: widget.cabinetId!),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        // Tampilkan fallback data
                        Expanded(child: _buildShelvesList(fallbackShelves)),
                      ],
                    );
                  }
                  // Initial state atau unknown state - gunakan fallback data
                  else {
                    return _buildShelvesList(fallbackShelves);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShelvesList(List<Map<String, dynamic>> shelves) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        if (widget.cabinetId != null) {
          context.read<LocatorBloc>().add(
            GetShelves(cabinetId: widget.cabinetId!),
          );
          // Wait for the operation to complete
          await Future.delayed(const Duration(milliseconds: 500));
        }
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: shelves.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildShelfItem(context, shelves[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_module_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No shelves found',
            style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'This cabinet has no shelves yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Shelf'),
            onPressed: () async {
              // Navigate to add shelf page
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<LocatorBloc>(),
                    child: ShelfAddPage(
                      cabinetId: widget.cabinetId!,
                      cabinetName: widget.cabinetName,
                    ),
                  ),
                ),
              );

              // Refresh shelves if shelf was added
              if (result == true && widget.cabinetId != null) {
                context.read<LocatorBloc>().add(
                  GetShelves(cabinetId: widget.cabinetId!),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShelfItem(BuildContext context, Map<String, dynamic> shelf) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shelf Header
            Row(
              children: [
                // Shelf Icon & Label
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.view_module_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shelf['shelfLabel'] ?? 'Unknown Shelf',
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (shelf['assetCount'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${shelf['assetCount']} assets stored',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Shelf Status Badge (optional)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Active',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons - FIX OVERFLOW ISSUE
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildActionButton(
                    context: context,
                    icon: Icons.visibility_outlined,
                    label: 'Instances',
                    color: AppColors.primary,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.shelfStored,
                        arguments: {
                          'shelfId': shelf['shelfId'],
                          'shelfLabel': shelf['shelfLabel'],
                          'cabinetId': widget.cabinetId, // Tambahkan cabinetId
                          'cabinetName':
                              widget.cabinetName, // Tambahkan cabinetName
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context: context,
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    color: AppColors.warning,
                    onPressed: () async {
                      // Convert Map to Shelf object
                      final Shelf shelfToEdit = Shelf(
                        shelfId: int.parse(shelf['shelfId'] ?? '0'),
                        shelfLabel: shelf['shelfLabel'] ?? '',
                      );

                      // Navigate to edit page dengan direct navigation
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: context.read<LocatorBloc>(),
                            child: ShelfEditPage(
                              shelf: shelfToEdit,
                              cabinetId: widget.cabinetId!,
                              cabinetName: widget.cabinetName,
                            ),
                          ),
                        ),
                      );

                      // Refresh shelves if shelf was edited
                      if (result == true && widget.cabinetId != null) {
                        context.read<LocatorBloc>().add(
                          GetShelves(cabinetId: widget.cabinetId!),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context: context,
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: AppColors.error,
                    onPressed: () {
                      _showDeleteConfirmation(context, shelf);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 80), // Prevent shrinking
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: color.withOpacity(0.05),
        ),
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> shelf,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.error, size: 24),
              const SizedBox(width: 12),
              Text(
                'Delete Shelf',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this shelf?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Text(
                  'Shelf: ${shelf['shelfLabel'] ?? 'Unknown'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone. All assets in this shelf will need to be relocated.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.delete_forever, size: 18),
              label: Text(
                'Delete',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // TODO: Implement delete shelf functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Shelf "${shelf['shelfLabel']}" deleted'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
