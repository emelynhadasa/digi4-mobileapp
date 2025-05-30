import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digi4_mobile/blocs/locator/locator_bloc.dart';
import 'package:digi4_mobile/models/locator_model.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';

class ShelfEditPage extends StatefulWidget {
  final Shelf shelf;
  final String cabinetId;
  final String? cabinetName;

  const ShelfEditPage({
    super.key,
    required this.shelf,
    required this.cabinetId,
    this.cabinetName,
  });

  @override
  _ShelfEditPageState createState() => _ShelfEditPageState();
}

class _ShelfEditPageState extends State<ShelfEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  bool _isSubmitting = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.shelf.shelfLabel);
    _labelController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final hasChanges = _labelController.text.trim() != widget.shelf.shelfLabel;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('No changes to save'),
            ],
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Trigger EditShelf event via BLoC
    context.read<LocatorBloc>().add(
      EditShelf(
        shelfId: widget.shelf.shelfId,
        cabinetId: int.parse(widget.cabinetId),
        shelfLabel: _labelController.text.trim(),
      ),
    );
  }

  void _resetForm() {
    _labelController.text = widget.shelf.shelfLabel;
    setState(() {
      _hasChanges = false;
    });
  }

  void _showUnsavedChangesDialog() {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.warning, size: 24),
              SizedBox(width: 12),
              Text(
                'Unsaved Changes',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'You have unsaved changes. Do you want to save them before leaving?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(); // Exit without saving
              },
              child: Text(
                'Discard',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _saveChanges(); // Save and exit
              },
              child: Text(
                'Save',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocatorBloc, LocatorState>(
      listener: (context, state) {
        if (state is EditShelfSuccess) {
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
                    Text('Shelf updated successfully'),
                  ],
                ),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          }
        } else if (state is EditShelfFailure) {
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
                      child: Text('Failed to update shelf: ${state.error}'),
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
      child: PopScope(
        canPop: !_hasChanges,
        onPopInvoked: (didPop) {
          if (!didPop && _hasChanges) {
            _showUnsavedChangesDialog();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (_hasChanges) {
                        _showUnsavedChangesDialog();
                      } else {
                        Navigator.pop(context);
                      }
                    },
            ),
            title: Text(
              'Edit Shelf',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (_hasChanges && !_isSubmitting)
                TextButton(
                  onPressed: _resetForm,
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              // Save Button di AppBar
              if (_hasChanges && !_isSubmitting)
                TextButton(
                  onPressed: _saveChanges,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
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
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: AppColors.warning,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Edit Shelf Details',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Modify the shelf label. This will update the shelf identification across the system.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Shelf ID Info (Read-only)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tag,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Shelf ID: ${widget.shelf.shelfId}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cabinet: ${widget.cabinetName ?? 'Unknown'} (ID: ${widget.cabinetId})',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Shelf Label Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shelf Label',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _labelController,
                        enabled: !_isSubmitting,
                        decoration: InputDecoration(
                          hintText: 'Enter shelf label',
                          prefixIcon: Icon(
                            Icons.label_outline,
                            color: _isSubmitting
                                ? AppColors.textSecondary
                                : AppColors.textSecondary,
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
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3),
                              width: 1,
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
                          fillColor: _isSubmitting
                              ? AppColors.textSecondary.withOpacity(0.1)
                              : Colors.white,
                        ),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _isSubmitting
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),

                      // Suggestion chips
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            label: Text(
                              'Shelf A',
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
                                    _labelController.text = 'Shelf A';
                                  },
                          ),
                          ActionChip(
                            label: Text(
                              'Top Level',
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
                                    _labelController.text = 'Top Level';
                                  },
                          ),
                          ActionChip(
                            label: Text(
                              'Bottom Level',
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
                                    _labelController.text = 'Bottom Level';
                                  },
                          ),
                          ActionChip(
                            label: Text(
                              'Middle Shelf',
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
                                    _labelController.text = 'Middle Shelf';
                                  },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

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
                          Expanded(
                            child: Text(
                              'You have unsaved changes. Click "Save Changes" to apply them.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Original vs New Value Comparison
                  if (_hasChanges) ...[
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Changes Preview:',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'From: ',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.info,
                                ),
                              ),
                              Text(
                                '"${widget.shelf.shelfLabel}"',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'To: ',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.info,
                                ),
                              ),
                              Text(
                                '"${_labelController.text.trim()}"',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _isSubmitting
                                  ? AppColors.textSecondary
                                  : AppColors.error,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  if (_hasChanges) {
                                    _showUnsavedChangesDialog();
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _isSubmitting
                                  ? AppColors.textSecondary
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),

                      // Save Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_isSubmitting || !_hasChanges)
                                ? AppColors.textSecondary
                                : AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: (_isSubmitting || !_hasChanges) ? 0 : 2,
                          ),
                          onPressed: (_isSubmitting || !_hasChanges)
                              ? null
                              : _saveChanges,
                          child: _isSubmitting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
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
                                      'Updating Shelf...',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _hasChanges
                                          ? Icons.save_outlined
                                          : Icons.check_circle_outline,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      _hasChanges
                                          ? 'Save Changes'
                                          : 'No Changes',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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
