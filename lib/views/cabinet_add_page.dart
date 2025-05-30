import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digi4_mobile/blocs/locator/locator_bloc.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';

class CabinetAddPage extends StatefulWidget {
  final String plantId;

  const CabinetAddPage({super.key, required this.plantId});

  @override
  _CabinetAddPageState createState() => _CabinetAddPageState();
}

class _CabinetAddPageState extends State<CabinetAddPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _cabinetNameController = TextEditingController();
  final TextEditingController _cabinetTypeController = TextEditingController();
  final TextEditingController _shelfCountController = TextEditingController();
  final TextEditingController _manualLabelsController = TextEditingController();

  // Form State
  String _labelMode = 'auto'; // 'auto' or 'manual'
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Set default shelf count
    _shelfCountController.text = '5';
  }

  void _onLabelModeChanged(String? value) {
    setState(() {
      _labelMode = value ?? 'auto';
      // Clear manual labels when switching to auto
      if (_labelMode == 'auto') {
        _manualLabelsController.clear();
      }
    });
  }

  Future<void> _submitCabinet() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate manual labels if manual mode is selected
    if (_labelMode == 'manual' && _manualLabelsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter manual labels when manual mode is selected',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create cabinet via BLoC
      context.read<LocatorBloc>().add(
        AddCabinet(
          plantId: widget.plantId,
          cabinetName: _cabinetNameController.text.trim(),
          cabinetType: _cabinetTypeController.text.trim(),
          labelMode: _labelMode,
          shelfCount: int.parse(_shelfCountController.text.trim()),
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
    _cabinetNameController.clear();
    _cabinetTypeController.clear();
    _shelfCountController.text = '5';
    _manualLabelsController.clear();
    setState(() {
      _labelMode = 'auto';
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocatorBloc, LocatorState>(
      listener: (context, state) {
        if (state is AddCabinetSuccess) {
          setState(() {
            _isSubmitting = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Cabinet created successfully'),
                  ],
                ),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          }
        } else if (state is AddCabinetFailure) {
          setState(() {
            _isSubmitting = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Failed to create cabinet: ${state.error}'),
                    ),
                  ],
                ),
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
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          ),
          title: Text(
            'Add New Cabinet',
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
                            Icons.add_business_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Create New Cabinet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Fill in the cabinet details below. You can choose to auto-generate shelf labels or manually specify them.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Plant ID Info (Read-only)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.factory_outlined,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Plant ID: ${widget.plantId}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Cabinet Name Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cabinet Name',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _cabinetNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter cabinet name (e.g., Storage Unit A)',
                        prefixIcon: Icon(
                          Icons.inventory_2_outlined,
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
                      textCapitalization: TextCapitalization.words,
                      enabled: !_isSubmitting,
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Cabinet Type Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cabinet Type',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _cabinetTypeController,
                      decoration: InputDecoration(
                        hintText: 'Enter cabinet type (e.g., Large Metal)',
                        prefixIcon: Icon(
                          Icons.category_outlined,
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
                      textCapitalization: TextCapitalization.words,
                      enabled: !_isSubmitting,
                    ),

                    // Suggestion chips for cabinet types
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          label: Text(
                            'Large Metal',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  _cabinetTypeController.text = 'Large Metal';
                                },
                        ),
                        ActionChip(
                          label: Text(
                            'Small Metal',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  _cabinetTypeController.text = 'Small Metal';
                                },
                        ),
                        ActionChip(
                          label: Text(
                            'Wood Cabinet',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  _cabinetTypeController.text = 'Wood Cabinet';
                                },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Shelf Count Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shelf Count',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _shelfCountController,
                      decoration: InputDecoration(
                        hintText: 'Enter number of shelves',
                        prefixIcon: Icon(
                          Icons.view_module_outlined,
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
                      keyboardType: TextInputType.number,
                      enabled: !_isSubmitting,
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Label Mode Radio Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Label Mode',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.formBorder,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: Text(
                              'Auto-generate',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'System will automatically generate shelf labels',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            value: 'auto',
                            groupValue: _labelMode,
                            onChanged: _isSubmitting
                                ? null
                                : _onLabelModeChanged,
                            activeColor: AppColors.primary,
                          ),
                          Divider(height: 1, color: AppColors.formBorder),
                          RadioListTile<String>(
                            title: Text(
                              'Determine manually',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Specify custom labels for each shelf',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            value: 'manual',
                            groupValue: _labelMode,
                            onChanged: _isSubmitting
                                ? null
                                : _onLabelModeChanged,
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Manual Labels Field (conditional)
                if (_labelMode == 'manual') ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manual Labels',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _manualLabelsController,
                        decoration: InputDecoration(
                          hintText:
                              'Enter shelf labels separated by comma (e.g., Shelf-A, Shelf-B, Shelf-C)',
                          prefixIcon: Icon(
                            Icons.label_outline,
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
                        maxLines: 3,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textCapitalization: TextCapitalization.words,
                        enabled: !_isSubmitting,
                      ),

                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.info.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.info,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Separate each label with a comma. Number of labels must match the shelf count.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.info,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],

                // Helper Text
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates_outlined,
                        color: AppColors.success,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cabinet will be created with the specified configuration. Shelves will be automatically set up based on your settings.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
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

                    // Create Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitCabinet,
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
                                    'Creating Cabinet...',
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
                                    Icons.add_business_outlined,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Create Cabinet',
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
    _cabinetNameController.dispose();
    _cabinetTypeController.dispose();
    _shelfCountController.dispose();
    _manualLabelsController.dispose();
    super.dispose();
  }
}
