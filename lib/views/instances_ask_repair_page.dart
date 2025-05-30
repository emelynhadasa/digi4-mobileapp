import 'dart:io';

import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InstanceAskRepairPage extends StatefulWidget {
  // Menerima data instance yang akan diperbaiki
  final Map<String, dynamic> instance;

  const InstanceAskRepairPage({super.key, required this.instance});

  @override
  State<InstanceAskRepairPage> createState() => _InstanceAskRepairPageState();
}

class _InstanceAskRepairPageState extends State<InstanceAskRepairPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _remarksController = TextEditingController();

  XFile? _selectedImage;
  bool _isLoading = false;

  // Method untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  void _handleSubmitRequest() {
    // Validasi form sebelum melanjutkan
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Di sini Anda akan memanggil event BLoC untuk mengirim permintaan perbaikan
      // context.read<InstancesBloc>().add(InstanceRepairRequested(
      //   instanceId: widget.instance['instanceId'],
      //   remarks: _remarksController.text,
      //   imagePath: _selectedImage?.path
      // ));

      // Simulasi proses network call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Repair request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Repair',
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
            Text(
              widget.instance['InstanceId'] ?? '',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Submitting request...',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Textfield untuk Remarks
                    Text(
                      'Damage Description',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _remarksController,
                      decoration: InputDecoration(
                        hintText: 'Describe the damage or issue here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description of the damage.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Upload Gambar
                    Text(
                      'Upload Photo',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.formBorder),
                          borderRadius: BorderRadius.circular(12),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(File(_selectedImage!.path)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 48,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.7),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to upload photo',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Tombol Submit Request
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.buttonText,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _handleSubmitRequest,
                        child: Text(
                          'Submit Request',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.buttonText,
                          ),
                        ),
                      ),
                    ),
                  ],
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
