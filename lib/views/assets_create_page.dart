import 'dart:io';

import 'package:digi4_mobile/blocs/asset/assets_bloc.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class CreateAssetPage extends StatefulWidget {
  const CreateAssetPage({super.key});

  @override
  _CreateAssetPageState createState() => _CreateAssetPageState();
}

class _CreateAssetPageState extends State<CreateAssetPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _specsController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  String? _selectedCategory;
  XFile? _selectedImage;
  bool _isLoading = false;

  final List<String> _assetCategories = ['Consumable', 'Reusable'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  void _handleCreateAsset() {
    if (_formKey.currentState!.validate()) {
      // Persiapkan data aset sesuai struktur API
      final Map<String, dynamic> assetData = {
        "AssetName": _nameController.text,
        "Brand": _brandController.text,
        "Specs": _specsController.text,
        "AssetCategoryId": _selectedCategory == 'Consumable' ? 1 : 2,
        "UnitOfMeasure": _selectedCategory == 'Consumable' ? _unitController.text : null,
      };

      // Set loading state
      setState(() {
        _isLoading = true;
      });

      // Dispatch create asset request
      context.read<AssetsBloc>().add(
        AssetCreateRequested(
          assetData: assetData,
          imagePath: _selectedImage?.path,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // BlocListener untuk menangani state changes
    return BlocListener<AssetsBloc, AssetsState>(
      listener: (context, state) {
        if (state is AssetCreateSuccess) {
          setState(() {
            _isLoading = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Asset created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back
          Navigator.of(context).pop();
        } else if (state is AssetCreateFailure) {
          setState(() {
            _isLoading = false;
          });

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create asset: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(
            'Create New Asset',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Creating asset...', style: AppTextStyles.bodyMedium),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Asset Category Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
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
                        value: _selectedCategory,
                        items: _assetCategories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) =>
                            value == null ? 'Please select category' : null,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
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
                          labelText: 'Specifications',
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

                      // Conditional Unit Measure
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

                      // Image Upload
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.formBorder),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _selectedImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload,
                                      size: 40,
                                      color: AppColors.textSecondary,
                                    ),
                                    Text(
                                      'Tap to upload photo',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Create Button
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
                          onPressed: _handleCreateAsset,
                          child: Text(
                            'Create Asset',
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
    _nameController.dispose();
    _brandController.dispose();
    _specsController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}
