import 'dart:convert';
import 'dart:io';
import 'package:digi4_mobile/blocs/asset/assets_bloc.dart';
import 'package:digi4_mobile/blocs/repair_request/repair_request_bloc.dart';
import 'package:digi4_mobile/models/assets_model.dart';
import 'package:digi4_mobile/models/instance_model.dart';
import 'package:digi4_mobile/services/repair_service.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class NewRepairRequestPage extends StatefulWidget {
  const NewRepairRequestPage({super.key});

  @override
  _NewRepairRequestPageState createState() => _NewRepairRequestPageState();
}

class _NewRepairRequestPageState extends State<NewRepairRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _remarksController = TextEditingController();
  final RepairService _repairService = RepairService();

  String? _selectedAsset;
  String? _selectedInstance;
  XFile? _selectedImage;

  // Data dari API
  List<AssetsModel> _assets = [];
  List<InstanceModel> _instances = [];
  bool _loadingAssets = true;
  bool _loadingInstances = false;
  bool _isSubmitting = false;

  // Map untuk menyimpan asset instances berdasarkan nama asset
  final Map<String, List<String>> _assetInstances = {};
  Map<String, int> _assetNameToId = {}; // Map nama asset ke ID
  final Map<String, int> _instanceNameToId = {}; // Map nama instance ke ID

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      setState(() {
        _loadingAssets = true;
      });

      // Load assets from BLoC
      context.read<AssetsBloc>().add(AssetsRequested());
    } catch (e) {
      print('Error loading assets: $e');
      setState(() {
        _loadingAssets = false;
      });
    }
  }

  Future<void> _loadInstancesByAssetId(int assetId, String assetName) async {
    print(
      'Loading instances for asset ID: $assetId, name: $assetName',
    ); // Debug

    try {
      setState(() {
        _loadingInstances = true;
        _selectedInstance = null;
        _assetInstances[assetName] = [];
      });

      final allInstances = await _repairService.getInstancesByAssetId(assetId);
      print('Loaded ${allInstances.length} total instances'); // Debug

      // Filter hanya instances yang condition-nya "Damaged"
      final damagedInstances = allInstances
          .where((instance) => instance.condition.toLowerCase() == 'damaged')
          .toList();

      print(
        'Filtered to ${damagedInstances.length} damaged instances',
      ); // Debug

      List<String> instanceNames = [];
      Map<String, int> tempInstanceNameToId = {};

      for (var instance in damagedInstances) {
        final displayName = instance.instanceDisplay;
        instanceNames.add(displayName);
        tempInstanceNameToId[displayName] = instance.instanceId;
        print(
          'Damaged Instance: $displayName -> ID: ${instance.instanceId}',
        ); // Debug
      }

      setState(() {
        _instances = damagedInstances; // Simpan hanya yang damaged
        _assetInstances[assetName] = instanceNames;
        _instanceNameToId.addAll(tempInstanceNameToId);
        _loadingInstances = false;
      });

      print('Asset instances updated: ${_assetInstances[assetName]}'); // Debug
      print('Instance name to ID mapping: $_instanceNameToId'); // Debug

      // Show message jika tidak ada damaged instances
      if (damagedInstances.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No damaged instances available for this asset'),
              backgroundColor: AppColors.warning,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading instances: $e');
      setState(() {
        _loadingInstances = false;
        _assetInstances[assetName] = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load instances: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<String?> _convertImageToBase64() async {
    if (_selectedImage == null) return null;

    try {
      final bytes = await File(_selectedImage!.path).readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  Future<void> _submitRepairRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedInstance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an instance'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get instance ID from selected instance name
      final instanceId = _instanceNameToId[_selectedInstance];
      if (instanceId == null) {
        throw Exception('Instance ID not found');
      }

      // Convert image to base64 if selected
      String? imageBase64;
      if (_selectedImage != null) {
        imageBase64 = await _convertImageToBase64();
      }

      // Create repair request via BLoC
      context.read<RepairRequestBloc>().add(
        RepairRequestCreateRequested(
          instanceId: instanceId,
          remarks: _remarksController.text.trim(),
          repairImageBase64: imageBase64,
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error preparing request: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen to AssetsBloc
        BlocListener<AssetsBloc, AssetsState>(
          listener: (context, state) {
            if (state is AssetsLoaded) {
              // Cast dengan benar dari List<dynamic> ke List<AssetsModel>
              final List<AssetsModel> reusableAssets = state.assets
                  .cast<AssetsModel>();

              List<String> assetNames = [];
              Map<String, int> tempAssetNameToId = {};

              for (var asset in reusableAssets) {
                assetNames.add(asset.assetName);
                tempAssetNameToId[asset.assetName] = asset.assetId;
              }

              setState(() {
                _assets = reusableAssets;
                _assetNameToId = tempAssetNameToId;
                _loadingAssets = false;
              });
            } else if (state is AssetsLoadFailure) {
              setState(() {
                _loadingAssets = false;
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to load assets: ${state.message}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
        ),

        // Listen to RepairRequestBloc
        BlocListener<RepairRequestBloc, RepairRequestState>(
          listener: (context, state) {
            if (state is RepairRequestCreateSuccess) {
              setState(() {
                _isSubmitting = false;
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context, true);
              }
            } else if (state is RepairRequestCreateFailure) {
              setState(() {
                _isSubmitting = false;
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(
            'New Repair Request',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: _loadingAssets
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Asset Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Asset',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.formBorder,
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        value: _selectedAsset,
                        items: _assets.map((AssetsModel asset) {
                          return DropdownMenuItem<String>(
                            value: asset.assetName,
                            child: Text(asset.assetName),
                          );
                        }).toList(),
                        validator: (value) =>
                            value == null ? 'Please select asset' : null,
                        onChanged: (value) {
                          print('Asset selected: $value'); // Debug log
                          setState(() {
                            _selectedAsset = value;
                            _selectedInstance = null;
                          });

                          // Load instances for selected asset
                          if (value != null) {
                            final assetId = _assetNameToId[value];
                            print('Asset ID for $value: $assetId'); // Debug log
                            if (assetId != null) {
                              _loadInstancesByAssetId(assetId, value);
                            } else {
                              print(
                                'Asset ID not found for: $value',
                              ); // Debug log
                            }
                          }
                        },
                      ),
                      SizedBox(height: 20),

                      // Instance Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Instance',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.formBorder,
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        value: _selectedInstance,
                        items: _loadingInstances
                            ? []
                            : (_assetInstances[_selectedAsset] ?? [])
                                  .map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  })
                                  .toList(),
                        validator: (value) =>
                            value == null ? 'Please select instance' : null,
                        onChanged: _selectedAsset != null && !_loadingInstances
                            ? (value) {
                                setState(() {
                                  _selectedInstance = value;
                                });
                              }
                            : null,
                      ),

                      // Loading indicator for instances
                      if (_loadingInstances) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Loading instances...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],

                      SizedBox(height: 20),

                      // Remarks
                      TextFormField(
                        controller: _remarksController,
                        decoration: InputDecoration(
                          labelText: 'Remarks',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.formBorder,
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        maxLines: 4,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter remarks' : null,
                      ),
                      SizedBox(height: 20),

                      // Image Upload
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _selectedImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      'Tap to upload photo (optional)',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )
                              : Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_selectedImage!.path),
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImage = null;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 30),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : _submitRepairRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.buttonText,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmitting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Creating Request...',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.buttonText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Submit Request',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.buttonText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }
}
