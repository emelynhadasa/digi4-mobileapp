import 'package:digi4_mobile/blocs/asset/assets_bloc.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InstanceCheckoutPage extends StatefulWidget {
  final Map<String, dynamic> instance;

  const InstanceCheckoutPage({super.key, required this.instance});

  @override
  State<InstanceCheckoutPage> createState() => _InstanceCheckoutPageState();
}

class _InstanceCheckoutPageState extends State<InstanceCheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default quantity for non-consumable items
    if (widget.instance['type'] != 'Consumable') {
      _quantityController.text = '1';
    }
  }

  void _handleCheckout() {
    if (_formKey.currentState!.validate()) {
      final instanceId =
          int.tryParse(widget.instance['instanceId']?.toString() ?? '0') ?? 0;

      if (instanceId == 0) {
        _showErrorSnackBar('Invalid instance ID');
        return;
      }

      final bool isConsumable = widget.instance['type'] == 'Consumable';
      final int quantity = isConsumable
          ? (int.tryParse(_quantityController.text) ?? 1)
          : 1;

      final checkoutData = {
        'InstanceId': instanceId,
        'Purpose': _purposeController.text.trim(),
        'QuantityConsumed': quantity,
        'Destination': _destinationController.text.trim(),
        'Remarks': _remarksController.text.trim(),
      };

      print('=== CHECKOUT DATA ===');
      print('Instance ID: $instanceId');
      print('Is Consumable: $isConsumable');
      print('Checkout Data: $checkoutData');

      context.read<AssetsBloc>().add(
        InstanceCheckoutRequested(
          instanceId: instanceId,
          jsonBody: checkoutData,
        ),
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
    final bool isConsumable = widget.instance['type'] == 'Consumable';
    final int availableQty = int.tryParse(
        widget.instance['qty']?.toString() ?? '0'
    ) ?? 0;

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
                'Checkout Instance',
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                'ID: ${widget.instance['instanceId']}',
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
                      state.message ?? 'Processing checkout...',
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
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_cart_checkout,
                                color: AppColors.success,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Checking out:',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.instance['assetName'] ?? 'Unknown Asset',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            'Type: ${widget.instance['type']} | Status: ${widget.instance['status']}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success.withOpacity(0.8),
                            ),
                          ),
                          if (isConsumable)
                            Text(
                              'Available Quantity: $availableQty',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Purpose Field
                    _buildSectionHeader(
                      'Purpose of Use',
                      Icons.assignment_outlined,
                    ),
                    _buildTextFormField(
                      controller: _purposeController,
                      labelText: 'Purpose',
                      hintText: 'e.g., Project Alpha, Regular Maintenance',
                      validator: (value) => value!.isEmpty
                          ? 'Please enter the purpose of use'
                          : null,
                    ),
                    SizedBox(height: 20),

                    // Destination Field
                    _buildSectionHeader(
                      'Destination',
                      Icons.location_on_outlined,
                    ),
                    _buildTextFormField(
                      controller: _destinationController,
                      labelText: 'Destination',
                      hintText: 'e.g., Site B, Workshop A, Building 3',
                      validator: (value) => value!.isEmpty
                          ? 'Please enter the destination'
                          : null,
                    ),
                    SizedBox(height: 20),

                    // Quantity Field (for consumable and reusable)
                    _buildSectionHeader(
                      'Quantity to Checkout',
                      Icons.inventory_outlined,
                    ),
                    _buildTextFormField(
                      controller: _quantityController,
                      labelText: 'Quantity',
                      hintText: isConsumable
                          ? 'Enter quantity (max: $availableQty)'
                          : 'Quantity (fixed: 1)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      enabled: isConsumable, // Only editable for consumable
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter quantity';
                        final qty = int.tryParse(value) ?? 0;
                        if (qty <= 0) return 'Quantity must be greater than 0';
                        if (isConsumable && qty > availableQty) {
                          return 'Quantity exceeds available stock';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Remarks Field
                    _buildSectionHeader(
                      'Remarks (Optional)',
                      Icons.note_outlined,
                    ),
                    _buildTextFormField(
                      controller: _remarksController,
                      labelText: 'Remarks',
                      hintText: 'Add any relevant notes here...',
                      maxLines: 4,
                    ),
                    SizedBox(height: 40),

                    // Checkout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: isLoading ? null : _handleCheckout,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Confirm Checkout',
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
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: !enabled,
        fillColor: !enabled ? AppColors.border.withOpacity(0.1) : null,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
    );
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _quantityController.dispose();
    _destinationController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}
