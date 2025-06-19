import 'package:digi4_mobile/blocs/locator/locator_bloc.dart';
import 'package:digi4_mobile/models/locator_model.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:digi4_mobile/views/cabinet_add_page.dart';
import 'package:digi4_mobile/views/cabinet_edit_page.dart';
import 'package:digi4_mobile/views/shelf_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';

class CabinetsPage extends StatefulWidget {
  final String? plantId;
  final String? plantName;

  const CabinetsPage({super.key, this.plantId, this.plantName});

  @override
  _CabinetsPageState createState() => _CabinetsPageState();
}

class _CabinetsPageState extends State<CabinetsPage> {
  // Data dummy sebagai fallback jika API gagal
  final List<Map<String, dynamic>> fallbackCabinets = [
    {'name': 'OpenCabinet=65', 'type': 'Open Cabinet', 'shelves': 5},
    {'name': 'OpenCabinet=67', 'type': 'Open Cabinet', 'shelves': 8},
  ];

  @override
  void initState() {
    super.initState();
    // Load cabinets saat halaman dibuka
    if (widget.plantId != null) {
      context.read<LocatorBloc>().add(GetCabinets(plantId: widget.plantId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: true,
        title: Text(
          'Cabinet in ${widget.plantName ?? 'Plant'}',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {
              if (widget.plantId != null) {
                context.read<LocatorBloc>().add(
                  GetCabinets(plantId: widget.plantId!),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Add Cabinet Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<LocatorBloc>(),
                          child: CabinetAddPage(plantId: widget.plantId!),
                        ),
                      ),
                    );

                    // Refresh cabinets jika berhasil menambah
                    if (result == true) {
                      context.read<LocatorBloc>().add(
                        GetCabinets(plantId: widget.plantId!),
                      );
                    }
                  },
                  child: Text(
                    'Add Cabinet',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.buttonText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Cabinet List dengan BlocBuilder
            Expanded(
              child: BlocBuilder<LocatorBloc, LocatorState>(
                builder: (context, state) {
                  // Loading state
                  if (state is GetCabinetsLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.buttonPrimary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading cabinets...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  // Success state - convert Cabinet to Map format
                  else if (state is GetCabinetsSuccess) {

                    final cabinetsData = state.cabinets
                        .map((cabinet) {

                      return {
                        'name': cabinet.cabinetName,
                        'type': cabinet.cabinetType,
                        'shelves': 0,
                        'cabinetId': cabinet.cabinetId,
                        'cabinetImage': cabinet.cabinetImage,
                        'cabinetImageBase64': cabinet.cabinetImageBase64,
                      };
                    }).toList();

                    if (cabinetsData.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildCabinetsList(cabinetsData);
                  }
                  // Error state - gunakan data fallback
                  else if (state is GetCabinetsFailure) {
                    return Column(
                      children: [
                        // Error message (optional)
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          padding: EdgeInsets.all(12),
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
                              SizedBox(width: 8),
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
                                  if (widget.plantId != null) {
                                    context.read<LocatorBloc>().add(
                                      GetCabinets(plantId: widget.plantId!),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        // Tampilkan fallback data
                        Expanded(child: _buildCabinetsList(fallbackCabinets)),
                      ],
                    );
                  }
                  // Initial state atau unknown state - gunakan fallback data
                  else {
                    return _buildCabinetsList(fallbackCabinets);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCabinetsList(List<Map<String, dynamic>> cabinets) {
    return RefreshIndicator(
      color: AppColors.buttonPrimary,
      onRefresh: () async {
        if (widget.plantId != null) {
          context.read<LocatorBloc>().add(
            GetCabinets(plantId: widget.plantId!),
          );
          // Wait for the operation to complete
          await Future.delayed(Duration(milliseconds: 500));
        }
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cabinets.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildCabinetItem(cabinets[index], context);
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
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No cabinets found',
            style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 8),
          Text(
            'Add a cabinet to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(Icons.add, size: 20),
            label: Text('Add First Cabinet'),
            onPressed: () {
              // TODO: Navigate to add cabinet page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Add Cabinet feature coming soon'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCabinetItem(Map<String, dynamic> cabinet, BuildContext context) {
    final String? imageUrl = cabinet['cabinetImage'] as String?;
    final String? base64 = cabinet['cabinetImageBase64'] as String?;

    Widget imageWidget;
    if (base64 != null && base64.trim().isNotEmpty) {
      try {
        final cleanBase64 = base64.contains(',') ? base64.split(',')[1] : base64;
        final bytes = base64Decode(cleanBase64);
        imageWidget = SizedBox(
          width: 80,
          height: 80,
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        print('⚠️ Error decoding base64: $e');
        imageWidget = SizedBox(
          width: 80,
          height: 80,
          child: Icon(Icons.broken_image, size: 40),
        );
      }
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      imageWidget = SizedBox(
        width: 80,
        height: 80,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: 40),
        ),
      );
    } else {
      imageWidget = SizedBox(
        width: 80,
        height: 80,
        child: Container(
          color: Colors.grey[200],
          child: Icon(Icons.photo, size: 40, color: Colors.grey[400]),
        ),
      );
    }

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
            // Cabinet Name and Type
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageWidget,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cabinet['name'] ?? 'Unknown Cabinet',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.info.withOpacity(0.3)),
                        ),
                        child: Text(
                          cabinet['type'] ?? 'Unknown Type',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Shelves info (if available)
            if (cabinet['shelves'] != null && cabinet['shelves'] > 0) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.view_module_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${cabinet['shelves']} shelves',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.buttonPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('See Shelf'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<LocatorBloc>(),
                          child: ShelfPage(
                            cabinetId: cabinet['cabinetId']?.toString(),
                            cabinetName: cabinet['name'],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  onPressed: () async {
                    // Convert Map to Cabinet object
                    final Cabinet cabinetToEdit = Cabinet(
                      cabinetId: cabinet['cabinetId'] ?? 0,
                      cabinetName: cabinet['name'] ?? '',
                      cabinetType: cabinet['type'] ?? '',
                    );

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<LocatorBloc>(),
                          child: CabinetEditPage(
                            cabinet: cabinetToEdit,
                            plantId: widget.plantId!,
                          ),
                        ),
                      ),
                    );

                    // Refresh cabinets jika berhasil mengedit
                    if (result == true) {
                      context.read<LocatorBloc>().add(
                        GetCabinets(plantId: widget.plantId!),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
