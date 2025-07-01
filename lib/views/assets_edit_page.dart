import 'dart:io';

import 'package:digi4_mobile/blocs/asset/assets_bloc.dart';
import 'package:digi4_mobile/models/assets_model.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digi4_mobile/config/constant.dart';
import 'package:image_picker/image_picker.dart';

class EditAssetPage extends StatefulWidget {
  final AssetsModel? asset;
  final int? assetId;

  // Ubah constructor untuk menerima asset object atau assetId
  const EditAssetPage({super.key, this.asset, this.assetId});

  @override
  _EditAssetPageState createState() => _EditAssetPageState();
}

class _EditAssetPageState extends State<EditAssetPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _specsController;
  late TextEditingController _unitController;
  late String _selectedCategory;
  XFile? _selectedImage;
  bool _isLoading = false;
  bool _dataLoaded = false;
  int? _assetId;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with empty values first
    _nameController = TextEditingController();
    _brandController = TextEditingController();
    _specsController = TextEditingController();
    _unitController = TextEditingController();
    _selectedCategory = 'Reusable'; // Default value

    // If asset object is directly provided
    if (widget.asset != null) {
      _loadAssetData(widget.asset!);
      _assetId = widget.asset!.assetId;
      _dataLoaded = true;
    }
    // If only assetId is provided, load from API
    else if (widget.assetId != null) {
      _assetId = widget.assetId;
      _isLoading = true;
      context.read<AssetsBloc>().add(
        AssetsLoadByIdRequested(assetId: widget.assetId!),
      );
    }
  }

  // Helper method to load data from AssetsModel
  void _loadAssetData(AssetsModel asset) {
    _nameController.text = asset.assetName;
    _brandController.text = asset.brand;
    _specsController.text = asset.specs;
    // _unitController.text = asset.unitOfMeasure ?? '';
    _selectedCategory = asset.assetCategoryId == 1 ? 'Consumable' : 'Reusable';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  void _handleUpdateAsset() {
    if (_formKey.currentState!.validate() && _assetId != null) {
      // Prepare update data according to required format
      print("ASSET ID: $_assetId");
      final Map<String, dynamic> updateData = {
        "AssetId": _assetId,
        "AssetName": _nameController.text,
        "Brand": _brandController.text,
        "Specs": _specsController.text,
        "AssetCategoryId": _selectedCategory == 'Consumable' ? 1 : 2,
        "UnitOfMeasure": _selectedCategory == 'Consumable'
            ? _unitController.text
            : null,
        "CreatedAt":
            widget.asset?.createdAt ?? DateTime.now().toIso8601String(),
      };

      // Set loading state
      setState(() {
        _isLoading = true;
      });

      // Dispatch update event
      context.read<AssetsBloc>().add(
        AssetUpdateRequested(assetId: _assetId!, assetData: updateData, imagePath: _selectedImage?.path,),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssetsBloc, AssetsState>(
      listener: (context, state) {
        if (state is AssetsLoadByIdLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is AssetsLoadByIdSuccess) {
          setState(() {
            _isLoading = false;
            _dataLoaded = true;
          });
          _loadAssetData(state.asset);
          _assetId = state.asset.assetId;
        } else if (state is AssetsUpdatedSuccess) {
          setState(() {
            _isLoading = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );

          context.read<AssetsBloc>().add(AssetsRequested());

          if (_assetId != null) {
            context.read<AssetsBloc>().add(
              AssetsLoadByIdRequested(assetId: _assetId!), // Reload detail
            );
          }
          Navigator.of(context).pop(true);
        } else if (state is AssetsLoadByIdFailure) {
          setState(() {
            _isLoading = false;
          });

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(
            'Edit Asset',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : !_dataLoaded
            ? Center(child: Text('No asset data available'))
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Image
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(_selectedImage!.path),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : widget.asset?.imageFileName != null &&
                                    widget.asset!.imageFileName.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              '${Constant.baseImageUrl}/AssetImg/${widget.asset!.imageFileName}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 64,
                                        color: AppColors.primary,
                                      ),
                                      Text(
                                        'Tap to change image',
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 64,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Tap to add image',
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Asset Type Display
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Category Type',
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
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _selectedCategory,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Name TextField
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
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
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter name' : null,
                      ),
                      SizedBox(height: 20),

                      // Brand TextField
                      TextFormField(
                        controller: _brandController,
                        decoration: InputDecoration(
                          labelText: 'Brand',
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
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter brand' : null,
                      ),
                      SizedBox(height: 20),

                      // Specs TextField
                      TextFormField(
                        controller: _specsController,
                        decoration: InputDecoration(
                          labelText: 'Specification',
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
                        maxLines: 3,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter specs' : null,
                      ),
                      SizedBox(height: 20),

                      // Unit of Measure (Conditional)
                      Visibility(
                        visible: _selectedCategory == 'Consumable',
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _unitController,
                              decoration: InputDecoration(
                                labelText: 'Unit of Measure',
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
                              validator: (value) {
                                if (_selectedCategory == 'Consumable' &&
                                    value!.isEmpty) {
                                  return 'Please enter unit';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonPrimary,
                            foregroundColor: AppColors.buttonText,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _handleUpdateAsset,
                          child: Text(
                            'Save Changes',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.buttonText,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _specsController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}
