import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digi4_mobile/blocs/locator/locator_bloc.dart';
import 'package:digi4_mobile/models/locator_model.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';

class CabinetEditPage extends StatefulWidget {
  final Cabinet cabinet; // Update parameter untuk menerima Cabinet object
  final String plantId; // Tambahkan plantId

  const CabinetEditPage({
    super.key,
    required this.cabinet,
    required this.plantId,
  });

  @override
  _CabinetEditPageState createState() => _CabinetEditPageState();
}

class _CabinetEditPageState extends State<CabinetEditPage> {
  // final List<String> _cabinetTypes = ['OpenCabinet', 'ClosedCabinet'];

  String? _selectedCabinetType;
  late TextEditingController _labelController;
  late TextEditingController _cabinetTypeController;
  bool _isSubmitting = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.cabinet.cabinetName);
    _cabinetTypeController = TextEditingController(
      text: widget.cabinet.cabinetType,
    );
    _selectedCabinetType = widget.cabinet.cabinetType;

    _labelController.addListener(_checkForChanges);
    _cabinetTypeController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final hasChanges =
        _labelController.text.trim() != widget.cabinet.cabinetName ||
        _selectedCabinetType != widget.cabinet.cabinetType;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  // void _onCabinetTypeChanged(String? value) {
  //   setState(() {
  //     _selectedCabinetType = value;
  //   });
  //   _checkForChanges();
  // }

  void _saveChanges() {
    if (_labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter cabinet name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedCabinetType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select cabinet type'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No changes to save'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Trigger EditCabinet event via BLoC
    context.read<LocatorBloc>().add(
      EditCabinet(
        cabinetId: widget.cabinet.cabinetId,
        plantId: widget.plantId,
        cabinetName: _labelController.text.trim(),
        cabinetType: _selectedCabinetType!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocatorBloc, LocatorState>(
      listener: (context, state) {
        if (state is EditCabinetSuccess) {
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
                    Text('Cabinet updated successfully'),
                  ],
                ),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          }
        } else if (state is EditCabinetFailure) {
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
                      child: Text('Failed to update cabinet: ${state.error}'),
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          ),
          title: Text(
            'Edit Cabinet',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          actions: [
            if (_hasChanges && !_isSubmitting)
              TextButton(
                onPressed: () {
                  // Reset form to original values
                  _labelController.text = widget.cabinet.cabinetName;
                  _selectedCabinetType = widget.cabinet.cabinetType;
                  setState(() {
                    _hasChanges = false;
                  });
                },
                child: Text(
                  'Reset',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabinet ID Info (Read-only)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tag, color: AppColors.textSecondary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Cabinet ID: ${widget.cabinet.cabinetId}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Cabinet Name Field
              TextFormField(
                controller: _labelController,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  labelText: 'Cabinet Name',
                  hintText: 'Enter cabinet name',
                  prefixIcon: Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.formBorder,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.formBorder,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: _isSubmitting
                      ? AppColors.textSecondary.withOpacity(0.1)
                      : Colors.white,
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _isSubmitting
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter cabinet name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cabinet Type Dropdown
              TextFormField(
                controller: TextEditingController(text: _selectedCabinetType),
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  labelText: 'Cabinet Type',
                  hintText:
                      'Enter cabinet type (e.g., OpenCabinet, ClosedCabinet)',
                  prefixIcon: Icon(
                    Icons.category_outlined,
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.formBorder,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.formBorder,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: _isSubmitting
                      ? AppColors.textSecondary.withOpacity(0.1)
                      : Colors.white,
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _isSubmitting
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCabinetType = value;
                  });
                  _checkForChanges();
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter cabinet type';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),

              // Changes indicator
              if (_hasChanges && !_isSubmitting)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
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
                        Icons.edit_outlined,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'You have unsaved changes',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _isSubmitting
                            ? AppColors.textSecondary
                            : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_isSubmitting || !_hasChanges)
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: (_isSubmitting || !_hasChanges) ? 0 : 2,
                    ),
                    onPressed: (_isSubmitting || !_hasChanges)
                        ? null
                        : _saveChanges,
                    child: _isSubmitting
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Updating...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.save_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                _hasChanges ? 'Save Changes' : 'No Changes',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.buttonText,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _labelController.removeListener(_checkForChanges);
    _labelController.dispose();
    super.dispose();
  }
}
