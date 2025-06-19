import 'package:digi4_mobile/blocs/locator/locator_bloc.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocatorAddPage extends StatefulWidget {
  const LocatorAddPage({super.key});

  @override
  _LocatorAddPageState createState() => _LocatorAddPageState();
}

class _LocatorAddPageState extends State<LocatorAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _plantNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submitPlant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create plant via BLoC
      context.read<LocatorBloc>().add(
        AddPlant(
          plantName: _plantNameController.text.trim(),
          address: _addressController.text.trim(),
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

  void _resetForm() {
    _formKey.currentState?.reset();
    _plantNameController.clear();
    _addressController.clear();
    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocatorBloc, LocatorState>(
      listener: (context, state) {
        if (state is AddPlantSuccess) {
          setState(() {
            _isSubmitting = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Plant added successfully'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          }
        } else if (state is AddPlantFailure) {
          setState(() {
            _isSubmitting = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context, true),
          ),
          title: Text(
            'Add New Plant',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : _resetForm,
              child: Text(
                'Reset',
                style: TextStyle(
                  color: _isSubmitting
                      ? AppColors.textSecondary
                      : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Description
                Container(
                  width: double.infinity,
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
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Plant Information',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add a new plant location to the locator system. Make sure to provide accurate plant name and complete address.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Plant Name Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plant Name',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _plantNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter plant name (e.g., East Plant)',
                        prefixIcon: Icon(
                          Icons.factory_outlined,
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.formBorder,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.formBorder,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.error,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter plant name';
                        }
                        if (value.trim().length < 2) {
                          return 'Plant name must be at least 2 characters';
                        }
                        if (value.trim().length > 100) {
                          return 'Plant name must be less than 100 characters';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                      enabled: !_isSubmitting,
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Address Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Enter complete address',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.formBorder,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.formBorder,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.error,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter address';
                        }
                        if (value.trim().length < 10) {
                          return 'Please enter a more complete address';
                        }
                        if (value.trim().length > 500) {
                          return 'Address must be less than 500 characters';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !_isSubmitting,
                    ),
                  ],
                ),
                SizedBox(height: 32),

                // Helper Text
                Container(
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
                        Icons.tips_and_updates_outlined,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Make sure the plant name is unique and the address is complete for easy identification.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _isSubmitting
                                ? AppColors.textSecondary
                                : AppColors.textSecondary,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _isSubmitting
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),

                    // Add Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitPlant,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSubmitting
                              ? AppColors.textSecondary
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: _isSubmitting ? 0 : 2,
                        ),
                        child: _isSubmitting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Adding Plant...',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_location_outlined,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add Plant',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
