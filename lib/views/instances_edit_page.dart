import 'package:digi4_mobile/blocs/asset/assets_bloc.dart';
import 'package:digi4_mobile/blocs/locator/locator_bloc.dart';
import 'package:digi4_mobile/models/locator_model.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InstanceEditPage extends StatefulWidget {
  final Map<String, dynamic> instance;

  const InstanceEditPage({super.key, required this.instance});

  @override
  _InstanceEditPageState createState() => _InstanceEditPageState();
}

class _InstanceEditPageState extends State<InstanceEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _restockThresholdController =
      TextEditingController();
  final TextEditingController _shelfLifeController = TextEditingController();
  final TextEditingController _lifetimeController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();

  // Selected values
  Plants? _selectedPlant;
  Cabinet? _selectedCabinet;
  Shelf? _selectedShelf;
  String? _selectedCondition;
  String? _selectedStatus; // TAMBAHAN: Field untuk status
  DateTime? _warrantyExpiryDate;

  // Available options from API
  List<Plants> _availablePlants = [];
  List<Cabinet> _availableCabinets = [];
  List<Shelf> _availableShelves = [];

  final List<Map<String, dynamic>> _conditionOptions = [
    {'value': 'Good', 'label': 'Good'},
    {'value': 'Damaged', 'label': 'Damaged'},
  ];

  // TAMBAHAN: Status options dengan visual indicators
  final List<Map<String, dynamic>> _statusOptions = [
    {
      'value': 'Available',
      'label': 'Available',
      'color': AppColors.success,
      'icon': Icons.check_circle_outline,
      'description': 'Item is available for use',
    },
    {
      'value': 'Missing',
      'label': 'Missing',
      'color': AppColors.error,
      'icon': Icons.error_outline,
      'description': 'Item is missing or lost',
    },
  ];

  late final bool _isConsumable;
  @override
  void initState() {
    super.initState();

    final typeString = widget.instance['type'] as String? ?? '';
    _isConsumable = typeString.toLowerCase() == 'consumable';

    // Load plants when page initializes
    context.read<LocatorBloc>().add(LoadPlants());
    _initializeFields();
  }

  void _initializeFields() {
    // Initialize form fields with current instance data
    _quantityController.text = widget.instance['qty']?.toString() ?? '1';
    _restockThresholdController.text =
        widget.instance['restockThreshold']?.toString() ?? '1';
    _shelfLifeController.text =
        widget.instance['shelfLife']?.toString() ?? '365';
    _lifetimeController.text = widget.instance['lifetime']?.toString() ?? '730';
    _serialNumberController.text = widget.instance['serialNumber'] ?? '';

    // Handle condition - SAFE VALUE ASSIGNMENT
    final instanceCondition = widget.instance['condition']?.toString();
    _selectedCondition =
        _conditionOptions.any((option) => option['value'] == instanceCondition)
        ? instanceCondition
        : 'Good'; // Default fallback

    // TAMBAHAN: Handle status - SAFE VALUE ASSIGNMENT
    final instanceStatus = widget.instance['status']?.toString();
    _selectedStatus =
        _statusOptions.any((option) => option['value'] == instanceStatus)
        ? instanceStatus
        : 'Available'; // Default fallback

    // Parse warranty date
    if (widget.instance['warrantyExpiryDate'] != null) {
      try {
        _warrantyExpiryDate = DateTime.parse(
          widget.instance['warrantyExpiryDate'],
        );
      } catch (e) {
        print('Error parsing warranty date: $e');
        _warrantyExpiryDate = DateTime.now().add(Duration(days: 365));
      }
    }

    print('=== EDIT INSTANCE PAGE ===');
    print('Instance ID: ${widget.instance['instanceId']}');
    print('Current Status: ${widget.instance['status']}');
    print('Selected Status: $_selectedStatus');
    print('Plant ID: ${widget.instance['plantId']}');
    print('Cabinet ID: ${widget.instance['cabinetId']}');
    print('Shelf ID: ${widget.instance['shelfId']}');
    print("TYPE = ${widget.instance.runtimeType}");
  }

  // Manual onChanged methods for user interaction
  void _onPlantChanged(Plants? plant) {
    setState(() {
      _selectedPlant = plant;
      _selectedCabinet = null; // Reset cabinet when plant changes manually
      _selectedShelf = null; // Reset shelf when plant changes manually
      _availableCabinets = []; // Clear cabinets
      _availableShelves = []; // Clear shelves
    });

    if (plant != null) {
      // Load cabinets for selected plant
      context.read<LocatorBloc>().add(
        GetCabinets(plantId: plant.plantId.toString()),
      );
    }
  }

  void _onCabinetChanged(Cabinet? cabinet) {
    setState(() {
      _selectedCabinet = cabinet;
      _selectedShelf = null; // Reset shelf when cabinet changes manually
      _availableShelves = []; // Clear shelves
    });

    if (cabinet != null) {
      // Load shelves for selected cabinet
      context.read<LocatorBloc>().add(
        GetShelves(cabinetId: cabinet.cabinetId.toString()),
      );
    }
  }

  void _onShelfChanged(Shelf? shelf) {
    setState(() {
      _selectedShelf = shelf;
    });
  }

  // AUTO-SELECTION METHODS - For initial data loading
  void _selectPlantById(int? plantId) {
    if (plantId != null && _availablePlants.isNotEmpty) {
      try {
        final plant = _availablePlants.firstWhere(
          (p) => p.plantId == plantId,
          orElse: () => _availablePlants.first,
        );

        setState(() {
          _selectedPlant = plant;
        });

        // Load cabinets for this plant
        context.read<LocatorBloc>().add(
          GetCabinets(plantId: plant.plantId.toString()),
        );

        print('Auto-selected plant: ${plant.plantName} (ID: ${plant.plantId})');
      } catch (e) {
        print('Error selecting plant by ID $plantId: $e');
      }
    }
  }

  void _selectCabinetById(int? cabinetId) {
    if (cabinetId != null && _availableCabinets.isNotEmpty) {
      try {
        final cabinet = _availableCabinets.firstWhere(
          (c) => c.cabinetId == cabinetId,
          orElse: () => _availableCabinets.first,
        );

        setState(() {
          _selectedCabinet = cabinet;
        });

        // Load shelves for this cabinet
        context.read<LocatorBloc>().add(
          GetShelves(cabinetId: cabinet.cabinetId.toString()),
        );

        print(
          'Auto-selected cabinet: ${cabinet.cabinetName} (ID: ${cabinet.cabinetId})',
        );
      } catch (e) {
        print('Error selecting cabinet by ID $cabinetId: $e');
      }
    }
  }

  void _selectShelfById(int? shelfId) {
    if (shelfId != null && _availableShelves.isNotEmpty) {
      try {
        final shelf = _availableShelves.firstWhere(
          (s) => s.shelfId == shelfId,
          orElse: () => _availableShelves.first,
        );

        setState(() {
          _selectedShelf = shelf;
        });

        print(
          'Auto-selected shelf: ${shelf.shelfLabel} (ID: ${shelf.shelfId})',
        );
      } catch (e) {
        print('Error selecting shelf by ID $shelfId: $e');
      }
    }
  }

  Future<void> _selectWarrantyDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _warrantyExpiryDate ?? DateTime.now().add(Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 3650)), // 10 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _warrantyExpiryDate) {
      setState(() {
        _warrantyExpiryDate = picked;
      });
    }
  }

  void _handleUpdateInstance() {
    if (_formKey.currentState!.validate()) {
      final instanceId = widget.instance['instanceId'];
      if (instanceId == null) {
        _showErrorSnackBar('Instance ID is required');
        return;
      }

      if (_selectedShelf == null) {
        _showErrorSnackBar('Please select a shelf');
        return;
      }

      // PERBAIKAN: Ensure consistent ID format and include InstanceId in body
      final instanceIdInt = int.tryParse(instanceId.toString()) ?? 0;

      if (instanceIdInt == 0) {
        _showErrorSnackBar('Invalid Instance ID format');
        return;
      }

      // Prepare updated instance data with INSTANCE ID in body
      final instanceData = {
        'InstanceId': instanceIdInt,
        'AssetId':
            int.tryParse(widget.instance['assetId']?.toString() ?? '0') ?? 0,
        'ShelfId': _selectedShelf!.shelfId,
        'PlantId': _selectedPlant!.plantId,
        'CabinetId': _selectedCabinet!.cabinetId,
        'Quantity': int.tryParse(_quantityController.text) ?? 1,
        'RestockThreshold': int.tryParse(_restockThresholdController.text) ?? 1,
        'ShelfLife': int.tryParse(_shelfLifeController.text) ?? 365,
        'Condition': _selectedCondition ?? 'Good',
        'Status': _selectedStatus ?? 'Available', // TAMBAHAN: Include status
        'WarrantyExpiryDate': _warrantyExpiryDate?.toUtc().toIso8601String(),
        'Lifetime': int.tryParse(_lifetimeController.text) ?? 730,
        'SerialNumber': _serialNumberController.text.trim(),
      };

      print('=== UPDATING INSTANCE ===');
      print('Instance ID (URL): $instanceIdInt');
      print('Instance ID (Body): ${instanceData['InstanceId']}');
      print('Asset ID: ${instanceData['AssetId']}');
      print('Status: ${instanceData['Status']}'); // TAMBAHAN: Log status
      print('Updated data: $instanceData');

      // Trigger BLoC event with consistent ID
      context.read<AssetsBloc>().add(
        AssetInstanceUpdateRequested(
          instanceId: instanceIdInt,
          instanceData: instanceData,
        ),
      );
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
    return MultiBlocListener(
      listeners: [
        // Assets BLoC listener for update instance
        BlocListener<AssetsBloc, AssetsState>(
          listener: (context, state) {
            if (state is AssetsUpdatedSuccess) {
              _showSuccessSnackBar(state.message);
              Navigator.of(context).pop(); // Return to detail page
            } else if (state is AssetsLoadByIdFailure) {
              _showErrorSnackBar(state.message);
            }
          },
        ),
        // Locator BLoC listener for loading plants, cabinets, shelves
        BlocListener<LocatorBloc, LocatorState>(
          listener: (context, state) {
            if (state is PlantsLoadedSuccess) {
              setState(() {
                _availablePlants = state.plants;
              });
              // After plants loaded, auto-select the current plant
              final currentPlantId = widget.instance['plantId'];
              if (currentPlantId != null) {
                _selectPlantById(int.tryParse(currentPlantId.toString()));
              }
              print('=== PLANTS LOADED FOR EDIT ===');
              print('Plants count: ${state.plants.length}');
              print('Trying to auto-select plant ID: $currentPlantId');
            } else if (state is GetCabinetsSuccess) {
              setState(() {
                _availableCabinets = state.cabinets;
              });
              // After cabinets loaded, auto-select the current cabinet
              final currentCabinetId = widget.instance['cabinetId'];
              if (currentCabinetId != null) {
                _selectCabinetById(int.tryParse(currentCabinetId.toString()));
              }
              print('=== CABINETS LOADED FOR EDIT ===');
              print('Cabinets count: ${state.cabinets.length}');
              print('Trying to auto-select cabinet ID: $currentCabinetId');
            } else if (state is GetShelvesSuccess) {
              setState(() {
                _availableShelves = state.shelves;
              });
              // After shelves loaded, auto-select the current shelf
              final currentShelfId = widget.instance['shelfId'];
              if (currentShelfId != null) {
                _selectShelfById(int.tryParse(currentShelfId.toString()));
              }
              print('=== SHELVES LOADED FOR EDIT ===');
              print('Shelves count: ${state.shelves.length}');
              print('Trying to auto-select shelf ID: $currentShelfId');
            } else if (state is PlantsLoadedFailure) {
              _showErrorSnackBar('Failed to load plants: ${state.error}');
            } else if (state is GetCabinetsFailure) {
              _showErrorSnackBar('Failed to load cabinets: ${state.error}');
            } else if (state is GetShelvesFailure) {
              _showErrorSnackBar('Failed to load shelves: ${state.error}');
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Edit Instance',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<AssetsBloc, AssetsState>(
          builder: (context, assetsState) {
            return BlocBuilder<LocatorBloc, LocatorState>(
              builder: (context, locatorState) {
                final isLoadingAssets = assetsState is AssetsLoadByIdLoading;
                final isLoadingLocator =
                    locatorState is PlantsLoading ||
                    locatorState is GetCabinetsLoading ||
                    locatorState is GetShelvesLoading;

                if (isLoadingAssets) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'Updating instance...',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Instance Info Header
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.info.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Editing Instance:',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.info,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.instance['instanceId']?.toString() ?? 'Unknown',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Asset: ${widget.instance['assetName'] ?? 'Unknown'}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.info,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),

                        // Location Selection Section
                        _buildSectionHeader(
                          'Location Selection',
                          Icons.location_on_outlined,
                        ),
                        SizedBox(height: 16),
                        _buildPlantDropdownFormField(
                          value: _selectedPlant,
                          items: _availablePlants,
                          isLoading: locatorState is PlantsLoading,
                          onChanged: _onPlantChanged,
                        ),
                        SizedBox(height: 20),
                        _buildCabinetDropdownFormField(
                          value: _selectedCabinet,
                          items: _availableCabinets,
                          isLoading: locatorState is GetCabinetsLoading,
                          enabled: _selectedPlant != null,
                          onChanged: _onCabinetChanged,
                        ),
                        SizedBox(height: 20),
                        _buildShelfDropdownFormField(
                          value: _selectedShelf,
                          items: _availableShelves,
                          isLoading: locatorState is GetShelvesLoading,
                          enabled: _selectedCabinet != null,
                          onChanged: _onShelfChanged,
                        ),
                        SizedBox(height: 32),

                        // Instance Details Section
                        _buildSectionHeader(
                          'Instance Details',
                          Icons.inventory_outlined,
                        ),
                        SizedBox(height: 16),

                        // ── Reusable‑only fields ──
                        if (!_isConsumable) ...[
                          _buildTextFormField(
                            controller: _serialNumberController,
                            labelText: 'Serial Number',
                            hintText: 'e.g., SN123456789',
                            validator: (value) => value!.isEmpty
                                ? 'Please enter serial number'
                                : null,
                          ),
                          SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    _buildStatusDropdownFormField(
                                      value: _selectedStatus,
                                      items: _statusOptions,
                                      labelText: 'Status',
                                      hintText: 'Select status',
                                      onChanged: (value) {
                                        setState(() => _selectedStatus = value);
                                      },
                                      validator: (value) =>
                                      value == null ? 'Please select status' : null,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Condition',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    _buildStringDropdownFormField(
                                      value: _selectedCondition,
                                      items: _conditionOptions,
                                      labelText: 'Condition',
                                      hintText: 'Select condition',
                                      onChanged: (value) {
                                        setState(() => _selectedCondition = value);
                                      },
                                      validator: (value) =>
                                      value == null ? 'Please select condition' : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          if (_selectedStatus != widget.instance['status']?.toString())
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.warning.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Status Change Detected',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.warning,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Changing from "${widget.instance['status']}" to "$_selectedStatus"',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.warning,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 20),

                          _buildDatePickerField(
                            labelText: 'Warranty Expiry Date',
                            selectedDate: _warrantyExpiryDate,
                            onTap: () => _selectWarrantyDate(context),
                            validator: (value) =>
                            _warrantyExpiryDate == null
                                ? 'Please select warranty expiry date'
                                : null,
                          ),
                          SizedBox(height: 20),

                          _buildTextFormField(
                            controller: _lifetimeController,
                            labelText: 'Lifetime (Days)',
                            hintText: 'e.g., 730',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) =>
                            value!.isEmpty ? 'Please enter lifetime' : null,
                          ),
                          SizedBox(height: 20),
                        ],

                        // ── Consumable‑only fields ──
                        if (_isConsumable) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextFormField(
                                  controller: _quantityController,
                                  labelText: 'Quantity',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) =>
                                  value!.isEmpty ? 'Please enter quantity' : null,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildTextFormField(
                                  controller: _restockThresholdController,
                                  labelText: 'Restock Threshold',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter restock threshold'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          _buildTextFormField(
                            controller: _shelfLifeController,
                            labelText: 'Shelf Life (Days)',
                            hintText: 'e.g., 365',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) =>
                            value!.isEmpty ? 'Please enter shelf life' : null,
                          ),
                          SizedBox(height: 20),
                        ],

                        // Update Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: (isLoadingAssets || isLoadingLocator)
                                ? null
                                : _handleUpdateInstance,
                            child: Text(
                              'Update Instance',
                              style: AppTextStyles.h4.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Section Header Widget
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Plant Dropdown Widget - SAFE VALUE HANDLING
  Widget _buildPlantDropdownFormField({
    required Plants? value,
    required List<Plants> items,
    required bool isLoading,
    required void Function(Plants?)? onChanged,
  }) {
    // SAFE VALUE CHECK
    Plants? safeValue;
    if (value != null && items.any((item) => item.plantId == value.plantId)) {
      safeValue = value;
    }

    return DropdownButtonFormField<Plants>(
      decoration: InputDecoration(
        labelText: 'Plant',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              )
            : null,
      ),
      value: safeValue, // USE SAFE VALUE
      hint: Text(
        isLoading ? 'Loading plants...' : 'Select a plant location',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      isExpanded: true,
      items: items.map((Plants plant) {
        return DropdownMenuItem<Plants>(
          value: plant,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  plant.plantName ?? 'Unnamed Plant',
                  style: AppTextStyles.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // if (plant.address != null && plant.address!.isNotEmpty)
                //   Text(
                //     plant.address!,
                //     style: AppTextStyles.bodySmall.copyWith(
                //       color: AppColors.textSecondary,
                //     ),
                //     overflow: TextOverflow.ellipsis,
                //     maxLines: 1,
                //   ),
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: isLoading ? null : onChanged,
      validator: (value) => value == null ? 'Please select a plant' : null,
    );
  }

  // Cabinet Dropdown Widget - SAFE VALUE HANDLING
  Widget _buildCabinetDropdownFormField({
    required Cabinet? value,
    required List<Cabinet> items,
    required bool isLoading,
    required bool enabled,
    required void Function(Cabinet?)? onChanged,
  }) {
    // SAFE VALUE CHECK
    Cabinet? safeValue;
    if (value != null &&
        items.any((item) => item.cabinetId == value.cabinetId)) {
      safeValue = value;
    }

    return DropdownButtonFormField<Cabinet>(
      decoration: InputDecoration(
        labelText: 'Cabinet',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: enabled
                ? AppColors.border
                : AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              )
            : null,
      ),
      value: enabled ? safeValue : null, // USE SAFE VALUE
      hint: Text(
        !enabled
            ? 'Select a plant first'
            : isLoading
            ? 'Loading cabinets...'
            : 'Select a cabinet',
        style: TextStyle(
          color: enabled
              ? AppColors.textSecondary
              : AppColors.textSecondary.withOpacity(0.5),
        ),
        overflow: TextOverflow.ellipsis,
      ),
      isExpanded: true,
      items: enabled && !isLoading
          ? items.map((Cabinet cabinet) {
              return DropdownMenuItem<Cabinet>(
                value: cabinet,
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cabinet.cabinetName ?? 'Unnamed Cabinet',
                        style: AppTextStyles.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      // if (cabinet.cabinetType != null &&
                      //     cabinet.cabinetType!.isNotEmpty)
                      //   Text(
                      //     'Type: ${cabinet.cabinetType}',
                      //     style: AppTextStyles.bodySmall.copyWith(
                      //       color: AppColors.textSecondary,
                      //     ),
                      //     overflow: TextOverflow.ellipsis,
                      //     maxLines: 1,
                      //   ),
                    ],
                  ),
                ),
              );
            }).toList()
          : [],
      onChanged: enabled && !isLoading ? onChanged : null,
      validator: (value) => value == null ? 'Please select a cabinet' : null,
    );
  }

  // Shelf Dropdown Widget - SAFE VALUE HANDLING
  Widget _buildShelfDropdownFormField({
    required Shelf? value,
    required List<Shelf> items,
    required bool isLoading,
    required bool enabled,
    required void Function(Shelf?)? onChanged,
  }) {
    // SAFE VALUE CHECK
    Shelf? safeValue;
    if (value != null && items.any((item) => item.shelfId == value.shelfId)) {
      safeValue = value;
    }

    return DropdownButtonFormField<Shelf>(
      decoration: InputDecoration(
        labelText: 'Shelf',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: enabled
                ? AppColors.border
                : AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              )
            : null,
      ),
      value: enabled ? safeValue : null, // USE SAFE VALUE
      hint: Text(
        !enabled
            ? 'Select a cabinet first'
            : isLoading
            ? 'Loading shelves...'
            : 'Select a shelf',
        style: TextStyle(
          color: enabled
              ? AppColors.textSecondary
              : AppColors.textSecondary.withOpacity(0.5),
        ),
        overflow: TextOverflow.ellipsis,
      ),
      isExpanded: true,
      items: enabled && !isLoading
          ? items.map((Shelf shelf) {
              return DropdownMenuItem<Shelf>(
                value: shelf,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    shelf.shelfLabel ?? 'Unnamed Shelf',
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              );
            }).toList()
          : [],
      onChanged: enabled && !isLoading ? onChanged : null,
      validator: (value) => value == null ? 'Please select a shelf' : null,
    );
  }

  // Enhanced TextFormField
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  // String Dropdown for simple string values - SAFE VALUE HANDLING
  Widget _buildStringDropdownFormField({
    required String? value,
    required List<Map<String, dynamic>> items,
    required String labelText,
    required String hintText,
    required void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    // SAFE VALUE CHECK
    String? safeValue;
    if (value != null && items.any((item) => item['value'] == value)) {
      safeValue = value;
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      value: safeValue, // USE SAFE VALUE
      hint: Text(hintText, style: TextStyle(color: AppColors.textSecondary)),
      isExpanded: true,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: SizedBox(
            width: double.infinity,
            child: Text(
              item['label'],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  // TAMBAHAN: Status Dropdown with enhanced visual design
  Widget _buildStatusDropdownFormField({
    required String? value,
    required List<Map<String, dynamic>> items,
    required String labelText,
    required String hintText,
    required void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    // SAFE VALUE CHECK
    String? safeValue;
    if (value != null && items.any((item) => item['value'] == value)) {
      safeValue = value;
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      value: safeValue,
      hint: Text(hintText, style: TextStyle(color: AppColors.textSecondary)),
      isExpanded: true,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Icon(item['icon'], color: item['color'], size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item['label'],
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: item['color'],
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      // Text(
                      //   item['description'],
                      //   style: AppTextStyles.bodySmall.copyWith(
                      //     color: AppColors.textSecondary,
                      //   ),
                      //   overflow: TextOverflow.ellipsis,
                      //   maxLines: 1,
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  // Date Picker Field
  Widget _buildDatePickerField({
    required String labelText,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'Tap to select date',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
      ),
      controller: TextEditingController(
        text: selectedDate != null
            ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
            : '',
      ),
      onTap: onTap,
      validator: validator,
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _restockThresholdController.dispose();
    _shelfLifeController.dispose();
    _lifetimeController.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }
}
