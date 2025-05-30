import 'package:digi4_mobile/blocs/asset/assets_bloc.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InstanceCheckinPage extends StatefulWidget {
  final Map<String, dynamic> instance;

  const InstanceCheckinPage({super.key, required this.instance});

  @override
  State<InstanceCheckinPage> createState() => _InstanceCheckinPageState();
}

class _InstanceCheckinPageState extends State<InstanceCheckinPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _remarksController = TextEditingController();

  String? _selectedCondition = 'Good'; // Default condition

  final List<Map<String, dynamic>> _conditionOptions = [
    {
      'value': 'Good',
      'label': 'Good',
      'color': AppColors.success,
      'icon': Icons.check_circle_outline,
      'description': 'Item is in good working condition',
    },
    {
      'value': 'Damaged',
      'label': 'Damaged',
      'color': AppColors.error,
      'icon': Icons.error_outline,
      'description': 'Item has damage and may need repair',
    },
  ];

  void _handleCheckin() {
    if (_formKey.currentState!.validate()) {
      final instanceId =
          int.tryParse(widget.instance['InstanceId']?.toString() ?? '0') ?? 0;

      if (instanceId == 0) {
        _showErrorSnackBar('Invalid instance ID');
        return;
      }

      final checkinData = {
        'InstanceId': instanceId,
        'LastCondition': _selectedCondition ?? 'Good',
        'Remarks': _remarksController.text.trim(),
      };

      print('=== CHECKIN DATA ===');
      print('Instance ID: $instanceId');
      print('Checkin Data: $checkinData');

      context.read<AssetsBloc>().add(
        InstanceCheckinRequested(instanceId: instanceId, jsonBody: checkinData),
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
    return BlocListener<AssetsBloc, AssetsState>(
      listener: (context, state) {
        if (state is AssetsUpdatedSuccess) {
          _showSuccessSnackBar(state.message);
          Navigator.of(context).pop(); // Return to detail page
        } else if (state is AssetsLoadByIdFailure) {
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
                'Check-in Instance',
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                'ID: ${widget.instance['InstanceId']}',
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
        body: BlocBuilder<AssetsBloc, AssetsState>(
          builder: (context, state) {
            final isLoading = state is AssetsLoadByIdLoading;

            if (isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      state.message ?? 'Processing check-in...',
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
                    // Instance Info
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.assignment_return,
                                color: AppColors.info,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Checking in:',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.instance['AssetName'] ?? 'Unknown Asset',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                          Text(
                            'Type: ${widget.instance['Type']} | Status: ${widget.instance['Status']}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.info.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Condition Selection
                    _buildSectionHeader(
                      'Return Condition',
                      Icons.assessment_outlined,
                    ),
                    Text(
                      'Please select the condition of the item upon return:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Condition Options
                    ..._conditionOptions.map((option) {
                      final isSelected = _selectedCondition == option['value'];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? option['color'].withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? option['color']
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: RadioListTile<String>(
                          title: Row(
                            children: [
                              Icon(
                                option['icon'],
                                color: option['color'],
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['label'],
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: option['color'],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    option['description'],
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          value: option['value'],
                          groupValue: _selectedCondition,
                          activeColor: option['color'],
                          onChanged: (value) {
                            setState(() {
                              _selectedCondition = value;
                            });
                          },
                          contentPadding: EdgeInsets.all(16),
                        ),
                      );
                    }),
                    SizedBox(height: 24),

                    // Remarks Field
                    _buildSectionHeader(
                      'Remarks (Optional)',
                      Icons.note_outlined,
                    ),
                    _buildTextFormField(
                      controller: _remarksController,
                      labelText: 'Remarks',
                      hintText: 'Add any notes about the return condition...',
                      maxLines: 4,
                    ),
                    SizedBox(height: 40),

                    // Check-in Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: isLoading ? null : _handleCheckin,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Confirm Check-in',
                              style: AppTextStyles.h4.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
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
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }
}
