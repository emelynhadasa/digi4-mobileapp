import 'package:digi4_mobile/blocs/asset/assets_bloc.dart';
import 'package:digi4_mobile/blocs/locator/locator_bloc.dart';
import 'package:digi4_mobile/models/locator_model.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InstanceCreatePage extends StatefulWidget {
  const InstanceCreatePage({super.key});

  @override
  _InstanceCreatePageState createState() => _InstanceCreatePageState();
}

class _InstanceCreatePageState extends State<InstanceCreatePage> {
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
  DateTime? _warrantyExpiryDate;
  String? assetId;
  String? assetName;

  // Available options from API
  List<Plants> _availablePlants = [];
  List<Cabinet> _availableCabinets = [];
  List<Shelf> _availableShelves = [];

  final List<Map<String, dynamic>> _conditionOptions = [
    {'value': 'New', 'label': 'New'},
    {'value': 'Good', 'label': 'Good'},
    {'value': 'Fair', 'label': 'Fair'},
    {'value': 'Poor', 'label': 'Poor'},
    {'value': 'Damaged', 'label': 'Damaged'},
  ];

  @override
  void initState() {
    super.initState();
    // Load plants when page initializes
    context.read<LocatorBloc>().add(LoadPlants());

    // Get arguments from navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          assetId = args['assetId']?.toString();
          assetName = args['assetName']?.toString();
        });
      }
      print('=== CREATE INSTANCE PAGE ===');
      print('Asset ID: $assetId');
      print('Asset Name: $assetName');
    });
  }

  void _onPlantChanged(Plants? plant) {
    setState(() {
      _selectedPlant = plant;
      _selectedCabinet = null; // Reset cabinet when plant changes
      _selectedShelf = null; // Reset shelf when plant changes
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
      _selectedShelf = null; // Reset shelf when cabinet changes
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

  void _handleCreateInstance() {
    if (_formKey.currentState!.validate()) {
      if (assetId == null) {
        _showErrorSnackBar('Asset ID is required');
        return;
      }

      if (_selectedShelf == null) {
        _showErrorSnackBar('Please select a shelf');
        return;
      }

      if (_warrantyExpiryDate == null) {
        _showErrorSnackBar('Please select warranty expiry date');
        return;
      }

      // Prepare instance data according to API specification
      final instanceData = {
        'AssetId': int.tryParse(assetId!) ?? 0,
        'ShelfId': _selectedShelf!.shelfId,
        'PlantId': _selectedPlant!.plantId,
        'CabinetId': _selectedCabinet!.cabinetId,
        'Quantity': int.tryParse(_quantityController.text) ?? 1,
        'RestockThreshold': int.tryParse(_restockThresholdController.text) ?? 1,
        'ShelfLife': int.tryParse(_shelfLifeController.text) ?? 365,
        'Condition': _selectedCondition ?? 'Good',
        'WarrantyExpiryDate': _warrantyExpiryDate!.toUtc().toIso8601String(),
        'Lifetime': _lifetimeController.text.trim(),
        'SerialNumber': _serialNumberController.text.trim(),
      };

      print('=== CREATING INSTANCE ===');
      print('Instance data: $instanceData');

      // Trigger BLoC event
      context.read<AssetsBloc>().add(
        AssetInstanceCreateRequested(instanceData: instanceData),
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
        // Assets BLoC listener for create instance
        BlocListener<AssetsBloc, AssetsState>(
          listener: (context, state) {
            if (state is AssetsUpdatedSuccess) {
              _showSuccessSnackBar(state.message);
              Navigator.of(context).pop(); // Return to instances page
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
              print('=== PLANTS LOADED ===');
              print('Plants count: ${state.plants.length}');
            } else if (state is GetCabinetsSuccess) {
              setState(() {
                _availableCabinets = state.cabinets;
              });
              print('=== CABINETS LOADED ===');
              print('Cabinets count: ${state.cabinets.length}');
            } else if (state is GetShelvesSuccess) {
              setState(() {
                _availableShelves = state.shelves;
              });
              print('=== SHELVES LOADED ===');
              print('Shelves count: ${state.shelves.length}');
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
            'Create Instance',
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
                          'Creating instance...',
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
                        // Asset Info Header
                        if (assetName != null) ...[
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Creating instance for:',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  assetName!,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (assetId != null) ...[
                                  SizedBox(height: 2),
                                  Text(
                                    'Asset ID: $assetId',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                        ],

                        // Location Selection Section
                        _buildSectionHeader(
                          'Location Selection',
                          Icons.location_on_outlined,
                        ),
                        SizedBox(height: 16),

                        // Plant Dropdown
                        _buildPlantDropdownFormField(
                          value: _selectedPlant,
                          items: _availablePlants,
                          isLoading: locatorState is PlantsLoading,
                          onChanged: _onPlantChanged,
                        ),
                        SizedBox(height: 20),

                        // Cabinet Dropdown (enabled only when plant is selected)
                        _buildCabinetDropdownFormField(
                          value: _selectedCabinet,
                          items: _availableCabinets,
                          isLoading: locatorState is GetCabinetsLoading,
                          enabled: _selectedPlant != null,
                          onChanged: _onCabinetChanged,
                        ),
                        SizedBox(height: 20),

                        // Shelf Dropdown (enabled only when cabinet is selected)
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

                        // Serial Number Field
                        _buildTextFormField(
                          controller: _serialNumberController,
                          labelText: 'Serial Number',
                          hintText: 'e.g., SN123456789',
                          validator: (value) => value!.isEmpty
                              ? 'Please enter serial number'
                              : null,
                        ),
                        SizedBox(height: 20),

                        // Condition Dropdown
                        _buildStringDropdownFormField(
                          value: _selectedCondition,
                          items: _conditionOptions,
                          labelText: 'Condition',
                          hintText: 'Select condition',
                          onChanged: (value) {
                            setState(() {
                              _selectedCondition = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select condition' : null,
                        ),
                        SizedBox(height: 20),

                        // Quantity and Restock Threshold Row
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
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter quantity'
                                    : null,
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

                        // Shelf Life and Lifetime Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                controller: _shelfLifeController,
                                labelText: 'Shelf Life (Days)',
                                hintText: 'e.g., 365',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter shelf life'
                                    : null,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _lifetimeController,
                                labelText: 'Lifetime (Days)',
                                hintText: 'e.g., 730',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter lifetime'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Warranty Expiry Date
                        _buildDatePickerField(
                          labelText: 'Warranty Expiry Date',
                          selectedDate: _warrantyExpiryDate,
                          onTap: () => _selectWarrantyDate(context),
                          validator: (value) => _warrantyExpiryDate == null
                              ? 'Please select warranty expiry date'
                              : null,
                        ),
                        SizedBox(height: 40),

                        // Create Button
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
                                : _handleCreateInstance,
                            child: Text(
                              'Create Instance',
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

  // Plant Dropdown Widget - FIXED OVERFLOW
  Widget _buildPlantDropdownFormField({
    required Plants? value,
    required List<Plants> items,
    required bool isLoading,
    required void Function(Plants?)? onChanged,
  }) {
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
      value: value,
      hint: Text(
        isLoading ? 'Loading plants...' : 'Select a plant location',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      isExpanded: true, // FIXED: Prevent overflow
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
                  overflow: TextOverflow.ellipsis, // FIXED: Handle overflow
                  maxLines: 1,
                ),
                // if (plant.address != null && plant.address!.isNotEmpty)
                //   Text(
                //     plant.address!,
                //     style: AppTextStyles.bodySmall.copyWith(
                //       color: AppColors.textSecondary,
                //     ),
                //     overflow: TextOverflow.ellipsis, // FIXED: Handle overflow
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

  // Cabinet Dropdown Widget - FIXED OVERFLOW
  Widget _buildCabinetDropdownFormField({
    required Cabinet? value,
    required List<Cabinet> items,
    required bool isLoading,
    required bool enabled,
    required void Function(Cabinet?)? onChanged,
  }) {
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
      value: enabled ? value : null,
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
        overflow: TextOverflow.ellipsis, // FIXED: Handle overflow in hint
      ),
      isExpanded: true, // FIXED: Prevent overflow
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
                        overflow:
                            TextOverflow.ellipsis, // FIXED: Handle overflow
                        maxLines: 1,
                      ),
                      // if (cabinet.cabinetType != null &&
                      //     cabinet.cabinetType!.isNotEmpty)
                      //   Text(
                      //     'Type: ${cabinet.cabinetType}',
                      //     style: AppTextStyles.bodySmall.copyWith(
                      //       color: AppColors.textSecondary,
                      //     ),
                      //     overflow:
                      //         TextOverflow.ellipsis, // FIXED: Handle overflow
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

  // Shelf Dropdown Widget - FIXED OVERFLOW
  Widget _buildShelfDropdownFormField({
    required Shelf? value,
    required List<Shelf> items,
    required bool isLoading,
    required bool enabled,
    required void Function(Shelf?)? onChanged,
  }) {
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
      value: enabled ? value : null,
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
        overflow: TextOverflow.ellipsis, // FIXED: Handle overflow in hint
      ),
      isExpanded: true, // FIXED: Prevent overflow
      items: enabled && !isLoading
          ? items.map((Shelf shelf) {
              return DropdownMenuItem<Shelf>(
                value: shelf,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    shelf.shelfLabel ?? 'Unnamed Shelf',
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis, // FIXED: Handle overflow
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

  // String Dropdown for simple string values - FIXED OVERFLOW
  Widget _buildStringDropdownFormField({
    required String? value,
    required List<Map<String, dynamic>> items,
    required String labelText,
    required String hintText,
    required void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      value: value,
      hint: Text(hintText, style: TextStyle(color: AppColors.textSecondary)),
      isExpanded: true, // FIXED: Prevent overflow
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: SizedBox(
            width: double.infinity,
            child: Text(
              item['label'],
              overflow: TextOverflow.ellipsis, // FIXED: Handle overflow
              maxLines: 1,
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
