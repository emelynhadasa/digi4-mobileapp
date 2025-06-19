import 'dart:io';

import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:digi4_mobile/blocs/repair_request/repair_request_bloc.dart';

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

  void _showErrorSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

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
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // 1) Ambil instanceId sebagai int
      final instanceId =
          int.tryParse(widget.instance['instanceId']?.toString() ?? '0') ?? 0;
      if (instanceId == 0) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Invalid instance ID');
        return;
      }

      // 2) Ambil teks remarks
      final remarks = _remarksController.text.trim();

      // 3) Ambil gambar (bila ada) dan ubah ke Base64
      String? imageBase64;
      if (_selectedImage != null) {
        final bytes = File(_selectedImage!.path).readAsBytesSync();
        imageBase64 = base64Encode(bytes);
      }

      // 4) Dispatch event ke RepairRequestBloc
      context.read<RepairRequestBloc>().add(
        RepairRequestCreateRequested(
          instanceId: instanceId,
          remarks: remarks,
          repairImageBase64: imageBase64,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isConsumable = widget.instance['type'] == 'Consumable';
    final int instanceId = int.tryParse(widget.instance['instanceId']?.toString() ?? '0') ?? 0;

    return BlocListener<RepairRequestBloc, RepairRequestState>(
      listener: (context, state) {
        if (state is RepairRequestCreateSuccess) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is RepairRequestCreateFailure) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ask for Repair',
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                'ID: $instanceId',
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
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian form: Remarks dan Upload gambar
                Text(
                  'Remarks',
                  style: AppTextStyles.labelMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Describe the issue...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Remarks cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Upload Image (optional)',
                  style: AppTextStyles.labelMedium,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text('Choose Image'),
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(height: 12),
                  Image.file(
                    File(_selectedImage!.path),
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ],
                const SizedBox(height: 24),

                // Tombol Submit
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
      ),
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }
}
