import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digi4_mobile/blocs/locator/locator_bloc.dart';
import 'package:digi4_mobile/models/locator_model.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';

class StoredInstanceShelfPage extends StatefulWidget {
  const StoredInstanceShelfPage({super.key});

  @override
  _StoredInstanceShelfPageState createState() =>
      _StoredInstanceShelfPageState();
}

// Update class _StoredInstanceShelfPageState

class _StoredInstanceShelfPageState extends State<StoredInstanceShelfPage> {
  // Update properties untuk shelf selection
  final List<Map<String, dynamic>> _fallbackInstances = [];

  List<Map<String, dynamic>> _availableShelves = []; // Untuk dropdown
  Map<String, dynamic>? _selectedShelf; // Ganti dari _selectedCabinet
  int? _editingIndex;
  bool _isMoving = false; // Loading state untuk move operation

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInstances();
      _loadAvailableShelves(); // Load shelves untuk dropdown
    });
  }

  void _loadInstances() {
    try {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args != null) {
        Map<String, dynamic>? argsMap;

        if (args is Map<String, dynamic>) {
          argsMap = args;
        } else if (args is Map) {
          argsMap = Map<String, dynamic>.from(args);
        }

        if (argsMap != null && argsMap['shelfId'] != null) {
          final shelfId = argsMap['shelfId'].toString();
          print('Loading instances for shelf: $shelfId');

          context.read<LocatorBloc>().add(GetInstances(shelfId: shelfId));
        } else {
          print('No shelfId found in arguments: $args');
        }
      } else {
        print('No arguments provided');
      }
    } catch (e) {
      print('Error in _loadInstances: $e');
    }
  }

  // Method baru untuk load available shelves
  void _loadAvailableShelves() {
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      Map<String, dynamic>? argsMap;

      if (args is Map<String, dynamic>) {
        argsMap = args;
      } else if (args is Map) {
        argsMap = Map<String, dynamic>.from(args);
      }

      if (argsMap != null && argsMap['cabinetId'] != null) {
        final cabinetId = argsMap['cabinetId'].toString();
        print('Loading shelves for cabinet: $cabinetId');

        // Load shelves untuk dropdown - gunakan event yang sama tapi untuk tujuan berbeda
        context.read<LocatorBloc>().add(GetShelves(cabinetId: cabinetId));
      }
    } catch (e) {
      print('Error loading available shelves: $e');
    }
  }

  List<Map<String, dynamic>> _convertInstancesToMap(List<Instances> instances) {
    return instances.map((instance) {
      return {
        'id': instance.instanceId.toString(),
        'instanceId': instance.instanceId, // Keep original for move operation
        'assetName': instance.assetName,
        'brand': instance.brand,
        'specs': instance.specs,
        'isEditing': false,
        'currentCabinet': 'Shelf ID: ${instance.currentShelfId}',
        'currentShelfId': instance.currentShelfId,
      };
    }).toList();
  }

  // Convert Shelf model to dropdown format
  void _updateAvailableShelves(List<Shelf> shelves) {
    setState(() {
      _availableShelves = shelves.map((shelf) {
        return <String, dynamic>{
          // Explicitly typed
          'shelfId': shelf.shelfId,
          'shelfLabel': shelf.shelfLabel,
          'displayText': '${shelf.shelfLabel} (ID: ${shelf.shelfId})',
        };
      }).toList();
    });

    print(
      'Updated available shelves: ${_availableShelves.length} shelves loaded',
    );
  }

  void _toggleEditMode(int index, List<Map<String, dynamic>> instances) {
    setState(() {
      if (_editingIndex == index) {
        _editingIndex = null;
        _selectedShelf = null;
      } else {
        _editingIndex = index;
        // Set current shelf as selected
        final currentShelfId = instances[index]['currentShelfId'];

        // Perbaikan: gunakan tipe yang tepat untuk orElse
        try {
          _selectedShelf = _availableShelves.firstWhere(
            (shelf) => shelf['shelfId'] == currentShelfId,
            orElse: () => <String, dynamic>{}, // Explicitly typed
          );

          // Jika shelf tidak ditemukan (empty map), set ke null
          if (_selectedShelf!.isEmpty) {
            _selectedShelf = null;
          }
        } catch (e) {
          print('Error finding shelf with ID $currentShelfId: $e');
          _selectedShelf = null;
        }
      }
    });
  }

  // Update _saveChanges untuk menggunakan MoveInstance BLoC
  void _moveInstance(int index, List<Map<String, dynamic>> instances) {
    if (_selectedShelf == null || _selectedShelf!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select a shelf'),
            ],
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final instanceId = instances[index]['instanceId'];
    final targetShelfId = _selectedShelf!['shelfId'];

    setState(() {
      _isMoving = true;
    });

    // Trigger MoveInstance via BLoC
    context.read<LocatorBloc>().add(
      MoveInstance(instanceId: instanceId, shelfId: targetShelfId),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safely get arguments
    Map<String, dynamic>? args;
    try {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is Map<String, dynamic>) {
        args = routeArgs;
      } else if (routeArgs is Map) {
        args = Map<String, dynamic>.from(routeArgs);
      }
    } catch (e) {
      print('Error parsing arguments: $e');
    }

    final shelfLabel = args?['shelfLabel']?.toString() ?? 'Unknown Shelf';
    final shelfId = args?['shelfId']?.toString();

    return BlocListener<LocatorBloc, LocatorState>(
      listener: (context, state) {
        // Handle MoveInstance result
        if (state is MoveInstanceSuccess) {
          setState(() {
            _isMoving = false;
            _editingIndex = null;
            _selectedShelf = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Instance moved successfully'),
                ],
              ),
              backgroundColor: AppColors.success,
            ),
          );

          // Reload instances after successful move
          _loadInstances();
        } else if (state is MoveInstanceFailure) {
          setState(() {
            _isMoving = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Failed to move instance: ${state.error}'),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        // Handle GetShelves result for dropdown
        else if (state is GetShelvesSuccess) {
          _updateAvailableShelves(state.shelves);
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
            'Stored Instances - $shelfLabel',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.textPrimary),
              tooltip: 'Refresh Instances',
              onPressed: () {
                _loadInstances();
                _loadAvailableShelves();
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
                      Icons.inventory_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shelf: $shelfLabel',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          BlocBuilder<LocatorBloc, LocatorState>(
                            builder: (context, state) {
                              String statusText = 'Loading...';
                              Color statusColor = AppColors.textSecondary;

                              if (state is GetInstancesSuccess) {
                                final count = state.instances.length;
                                statusText =
                                    '$count ${count == 1 ? 'Instance' : 'Instances'} Found';
                                statusColor = AppColors.success;
                              } else if (state is GetInstancesFailure) {
                                statusText = 'Using offline data';
                                statusColor = AppColors.warning;
                              } else if (state is GetInstancesLoading) {
                                statusText = 'Loading instances...';
                                statusColor = AppColors.primary;
                              } else if (state is MoveInstanceLoading) {
                                statusText = 'Moving instance...';
                                statusColor = AppColors.warning;
                              }

                              return Text(
                                statusText,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: statusColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Available Shelves Info (opsional)
              if (_availableShelves.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${_availableShelves.length} shelves available for moving',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Instances List
              Expanded(
                child: BlocBuilder<LocatorBloc, LocatorState>(
                  builder: (context, state) {
                    print('Current BLoC state: ${state.runtimeType}');

                    List<Map<String, dynamic>> instancesToShow =
                        _fallbackInstances;

                    if (state is GetInstancesLoading) {
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
                    } else if (state is GetInstancesSuccess) {
                      try {
                        instancesToShow = _convertInstancesToMap(
                          state.instances,
                        );
                        print('Converted ${state.instances.length} instances');
                      } catch (e) {
                        print('Error converting instances: $e');
                        instancesToShow = _fallbackInstances;
                      }

                      if (instancesToShow.isEmpty) {
                        return _buildEmptyState();
                      }
                    } else if (state is GetInstancesFailure) {
                      print('GetInstances failed: ${state.error}');
                      return Column(
                        children: [
                          // Error message
                          Container(
                            margin: const EdgeInsets.all(16),
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
                                  onPressed: () => _loadInstances(),
                                ),
                              ],
                            ),
                          ),
                          // Show fallback data
                          Expanded(child: _buildInstancesList(instancesToShow)),
                        ],
                      );
                    }

                    return _buildInstancesList(instancesToShow);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Update _buildInstancesList untuk menggunakan dropdown shelves
  Widget _buildInstancesList(List<Map<String, dynamic>> instances) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        _loadInstances();
        _loadAvailableShelves();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: instances.length,
        itemBuilder: (context, index) {
          final instance = instances[index];
          final isEditing = _editingIndex == index;

          return Card(
            color: Colors.white,
            elevation: isEditing ? 4 : 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isEditing
                  ? BorderSide(color: AppColors.primary, width: 2)
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instance Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.precision_manufacturing,
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
                              instance['assetName'] ?? 'Unknown Asset',
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${instance['id']}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isEditing
                              ? AppColors.warning.withOpacity(0.1)
                              : AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isEditing
                                ? AppColors.warning.withOpacity(0.3)
                                : AppColors.success.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Moving' : 'Stored',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isEditing
                                ? AppColors.warning
                                : AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Instance Details
                  _buildInfoRow('Brand', instance['brand'] ?? 'Unknown'),
                  _buildInfoRow(
                    'Specifications',
                    instance['specs'] ?? 'No specs',
                  ),

                  const SizedBox(height: 16),

                  // Edit Mode or Action Buttons
                  if (isEditing)
                    Column(
                      children: [
                        // Dropdown untuk shelves
                        DropdownButtonFormField<Map<String, dynamic>>(
                          value: _selectedShelf,
                          decoration: InputDecoration(
                            labelText: 'Move to Shelf',
                            helperText: 'Select destination shelf',
                            prefixIcon: Icon(
                              Icons.drive_file_move_outline,
                              color: AppColors.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.formBorder,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          items: _availableShelves.map((shelf) {
                            final isCurrentShelf =
                                shelf['shelfId'] == instance['currentShelfId'];
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: shelf,
                              child: Row(
                                children: [
                                  Icon(
                                    isCurrentShelf
                                        ? Icons.location_on
                                        : Icons.location_off,
                                    size: 16,
                                    color: isCurrentShelf
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    shelf['displayText'],
                                    style: TextStyle(
                                      color: isCurrentShelf
                                          ? AppColors.success
                                          : AppColors.textPrimary,
                                      fontWeight: isCurrentShelf
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  if (isCurrentShelf) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '(Current)',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: _isMoving
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedShelf = value;
                                  });
                                },
                        ),
                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _isMoving
                                  ? null
                                  : () => _toggleEditMode(index, instances),
                              child: Text(
                                'Cancel',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _isMoving
                                      ? AppColors.textSecondary
                                      : AppColors.error,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isMoving || _selectedShelf == null
                                    ? AppColors.textSecondary
                                    : AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: _isMoving ? 0 : 2,
                              ),
                              icon: _isMoving
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.save, size: 18),
                              label: Text(
                                _isMoving ? 'Moving...' : 'Move Instance',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: (_isMoving || _selectedShelf == null)
                                  ? null
                                  : () => _moveInstance(index, instances),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Current location info
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.info.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppColors.info,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    instance['currentCabinet'] ??
                                        'Unknown Location',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.info,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Move button
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.drive_file_move_outline,
                            size: 18,
                          ),
                          label: Text(
                            'Move',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _availableShelves.isEmpty
                              ? null
                              : () => _toggleEditMode(index, instances),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Keep existing methods
  Widget _buildEmptyState() {
    return Center(
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
            'This shelf has no stored instances',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Instances will appear here when they are stored on this shelf',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
