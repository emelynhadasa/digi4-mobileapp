import 'package:digi4_mobile/blocs/asset/assets_bloc.dart';
import 'package:digi4_mobile/models/assets_model.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:digi4_mobile/views/bulk_condition_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BulkOperationsPage extends StatefulWidget {
  const BulkOperationsPage({super.key});

  @override
  _BulkOperationsPageState createState() => _BulkOperationsPageState();
}

class _BulkOperationsPageState extends State<BulkOperationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentTab = 'checkout';
  List<BulkItems> _availableItems = [];
  List<BulkItems> _selectedItems = [];

  // TAMBAHAN: Map untuk menyimpan kondisi setiap item
  Map<int, String> _itemConditions = {};

  // Form controllers
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  // PERBAIKAN: Add scroll controller untuk better control
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Set default values
    _destinationController.text = 'Field Project Alpha';
    _remarksController.text = 'Bulk operation from mobile app';

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBulkInstances();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _destinationController.dispose();
    _remarksController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTab = _tabController.index == 0 ? 'checkout' : 'checkin';
        _selectedItems.clear();
        _itemConditions.clear(); // Clear conditions when changing tabs
        _updateDefaultTexts();
      });
      _loadBulkInstances();
    }
  }

  void _updateDefaultTexts() {
    if (_currentTab == 'checkout') {
      _destinationController.text = 'Field Project Alpha';
      _remarksController.text = 'Equipment checked out for field work';
    } else {
      _destinationController.text = 'Warehouse Storage';
      _remarksController.text = 'Equipment returned from field work';
    }
  }

  void _loadBulkInstances() {
    context.read<AssetsBloc>().add(AssetBulkInstancesLoaded(tab: _currentTab));
  }

  void _toggleItemSelection(BulkItems item) {
    if (!mounted || item.instanceId == null) return;

    setState(() {
      final index = _selectedItems.indexWhere(
        (selectedItem) => selectedItem.instanceId == item.instanceId,
      );

      if (index >= 0) {
        _selectedItems.removeAt(index);
        _itemConditions.remove(item.instanceId);
      } else {
        _selectedItems.add(item);
        // TAMBAHAN: Set default condition for checkin
        if (_currentTab == 'checkin') {
          _itemConditions[item.instanceId!] = 'Good';
        }
      }
    });
  }

  void _selectAllItems() {
    if (!mounted) return;

    setState(() {
      if (_selectedItems.length == _availableItems.length) {
        _selectedItems.clear();
        _itemConditions.clear();
      } else {
        _selectedItems = List.from(_availableItems);
        // TAMBAHAN: Set default conditions for all selected items in checkin
        if (_currentTab == 'checkin') {
          for (var item in _availableItems) {
            if (item.instanceId != null) {
              _itemConditions[item.instanceId!] = 'Good';
            }
          }
        }
      }
    });
  }

  // TAMBAHAN: Method untuk buka halaman condition
  void _openConditionPage() async {
    final result = await Navigator.push<Map<int, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => BulkConditionPage(
          selectedItems: _selectedItems,
          initialConditions: _itemConditions,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _itemConditions = result;
      });
    }
  }

  void _processOperation() {
    if (_selectedItems.isEmpty) {
      _showErrorSnackBar('Please select at least one instance');
      return;
    }

    // PERBAIKAN: Validation berdasarkan tab
    if (_currentTab == 'checkout' &&
        _destinationController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter destination');
      return;
    }

    // TAMBAHAN: Validation untuk checkin - pastikan semua item punya condition
    if (_currentTab == 'checkin') {
      for (var item in _selectedItems) {
        if (item.instanceId != null &&
            !_itemConditions.containsKey(item.instanceId)) {
          _showErrorSnackBar('Please set conditions for all selected items');
          return;
        }
      }
    }

    // PERBAIKAN: Different request body format for checkout vs checkin
    Map<String, dynamic> requestBody;

    if (_currentTab == 'checkout') {
      // Checkout format: InstanceIds, Destination, Remarks
      requestBody = {
        'InstanceIds': _selectedItems.map((item) => item.instanceId!).toList(),
        'Destination': _destinationController.text.trim(),
        'Remarks': _remarksController.text.trim().isNotEmpty
            ? _remarksController.text.trim()
            : 'Bulk checkout from mobile app',
      };
    } else {
      // TAMBAHAN: Checkin format: Items with conditions, Remarks
      final items = _selectedItems.map((item) {
        return {
          'InstanceId': item.instanceId!,
          'Condition': _itemConditions[item.instanceId] ?? 'Good',
        };
      }).toList();

      requestBody = {
        'Items': items,
        'Remarks': _remarksController.text.trim().isNotEmpty
            ? _remarksController.text.trim()
            : 'Bulk checkin from mobile app',
      };
    }

    print('=== BULK OPERATION DEBUG ===');
    print('Current tab: $_currentTab');
    print('Selected instances: ${_selectedItems.length}');
    print('Request body: $requestBody');

    if (_currentTab == 'checkout') {
      context.read<AssetsBloc>().add(AssetBulkCheckout(jsonBody: requestBody));
    } else {
      context.read<AssetsBloc>().add(AssetBulkCheckin(jsonBody: requestBody));
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        // PERBAIKAN: Add margin to avoid navbar overlap
        margin: EdgeInsets.only(
          bottom: 100, // Space for bottom navbar
          left: 16,
          right: 16,
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        // PERBAIKAN: Add margin to avoid navbar overlap
        margin: EdgeInsets.only(
          bottom: 100, // Space for bottom navbar
          left: 16,
          right: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Get screen dimensions for responsive design
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomNavHeight = 80.0; // Estimated bottom navbar height
    final appBarHeight = AppBar().preferredSize.height;
    final tabBarHeight = 48.0;

    return BlocListener<AssetsBloc, AssetsState>(
      listener: (context, state) {
        if (state is AssetsBulkLoadedSuccess) {
          if (state.assets.isNotEmpty) {
            setState(() {
              _availableItems = state.assets.first.data ?? [];
              _selectedItems.clear();
              _itemConditions.clear();
            });
            print('=== BULK ITEMS LOADED ===');
            print('Available items count: ${_availableItems.length}');
            for (var item in _availableItems) {
              print(
                '- Instance ${item.instanceId}: ${item.assetName} (${item.status})',
              );
            }
          }
        } else if (state is AssetsBulkCheckinSuccess) {
          _showSuccessSnackBar(state.message);
          setState(() {
            _selectedItems.clear();
            _itemConditions.clear();
          });
          _loadBulkInstances();
        } else if (state is AssetsBulkCheckoutSuccess) {
          _showSuccessSnackBar(state.message);
          setState(() {
            _selectedItems.clear();
            _itemConditions.clear();
          });
          _loadBulkInstances();
        } else if (state is AssetsBulkCheckinFailure) {
          _showErrorSnackBar(state.message);
        } else if (state is AssetsBulkCheckoutFailure) {
          _showErrorSnackBar(state.message);
        } else if (state is AssetsBulkLoadedFailure) {
          _showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Bulk Operations',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Checkout',
                        style: AppTextStyles.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Checkin',
                        style: AppTextStyles.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.textPrimary),
              onPressed: _loadBulkInstances,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: BlocBuilder<AssetsBloc, AssetsState>(
          builder: (context, state) {
            if (state is AssetsBulkLoading) {
              return _buildLoadingState();
            }

            // PERBAIKAN: Use Column with proper spacing
            return Column(
              children: [
                // PERBAIKAN: Scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: BouncingScrollPhysics(),
                    // PERBAIKAN: Add bottom padding to prevent navbar overlap
                    padding: EdgeInsets.only(
                      bottom:
                          bottomNavHeight + 20, // Extra space for action button
                    ),
                    child: Column(
                      children: [
                        // Header section
                        _buildHeaderSection(),

                        // Form section
                        _buildFormSection(),

                        // Condition button for checkin
                        if (_currentTab == 'checkin' &&
                            _selectedItems.isNotEmpty)
                          _buildConditionButton(),

                        // Items list
                        _availableItems.isEmpty
                            ? _buildEmptyState()
                            : _buildInstancesList(),
                      ],
                    ),
                  ),
                ),

                // PERBAIKAN: Fixed bottom action section
                _buildBottomActionSection(state),
              ],
            );
          },
        ),
      ),
    );
  }

  // PERBAIKAN: Improved instances list with better layout
  Widget _buildInstancesList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Available Items (${_availableItems.length})',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (_availableItems.isNotEmpty)
                  TextButton.icon(
                    onPressed: _selectAllItems,
                    icon: Icon(
                      _selectedItems.length == _availableItems.length
                          ? Icons.deselect
                          : Icons.select_all,
                      size: 16,
                    ),
                    label: Text(
                      _selectedItems.length == _availableItems.length
                          ? 'Deselect All'
                          : 'Select All',
                      style: AppTextStyles.bodySmall,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
              ],
            ),
          ),

          // Items list
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _availableItems.length,
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = _availableItems[index];
              final isSelected = _selectedItems.any(
                (selectedItem) => selectedItem.instanceId == item.instanceId,
              );

              return _buildInstanceCard(item, isSelected);
            },
          ),
        ],
      ),
    );
  }

  // PERBAIKAN: Responsive instance card
  Widget _buildInstanceCard(BulkItems item, bool isSelected) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        final isTablet = constraints.maxWidth > 600;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _toggleItemSelection(item),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox
                    Container(
                      width: isSmallScreen ? 20 : 24,
                      height: isSmallScreen ? 20 : 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: isSmallScreen ? 12 : 16,
                            )
                          : null,
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),

                    // Instance info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Instance ID and name
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Instance #${item.instanceId}',
                                      style:
                                          (isSmallScreen
                                                  ? AppTextStyles.bodyMedium
                                                  : AppTextStyles.bodyLarge)
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (item.assetName != null) ...[
                                      SizedBox(height: 2),
                                      Text(
                                        item.assetName!,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: isSmallScreen ? 11 : 13,
                                        ),
                                        maxLines: isTablet ? 3 : 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              // Status badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 6 : 8,
                                  vertical: isSmallScreen ? 3 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    item.status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item.status ?? 'Unknown',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: _getStatusColor(item.status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 9 : 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          // Location info
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: isSmallScreen ? 12 : 14,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.location ?? 'Unknown Location',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: isSmallScreen ? 10 : 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          // Condition for checkin (if selected)
                          if (_currentTab == 'checkin' &&
                              isSelected &&
                              item.instanceId != null &&
                              _itemConditions.containsKey(item.instanceId)) ...[
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 6 : 8,
                                vertical: isSmallScreen ? 3 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getConditionColor(
                                  _itemConditions[item.instanceId]!,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.assessment_outlined,
                                    size: isSmallScreen ? 10 : 12,
                                    color: _getConditionColor(
                                      _itemConditions[item.instanceId]!,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Condition: ${_itemConditions[item.instanceId]}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: _getConditionColor(
                                        _itemConditions[item.instanceId]!,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      fontSize: isSmallScreen ? 9 : 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // PERBAIKAN: Responsive header section
  Widget _buildHeaderSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;

        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    _currentTab == 'checkout' ? Icons.logout : Icons.login,
                    color: AppColors.primary,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bulk ${_currentTab == 'checkout' ? 'Checkout' : 'Checkin'}',
                          style:
                              (isSmallScreen
                                      ? AppTextStyles.bodyLarge
                                      : AppTextStyles.h4)
                                  .copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Available: ${_availableItems.length} • Selected: ${_selectedItems.length}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // PERBAIKAN: Responsive form section
  Widget _buildFormSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _currentTab == 'checkout'
                        ? Icons.send_outlined
                        : Icons.inventory_outlined,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _currentTab == 'checkout'
                        ? 'Checkout Details'
                        : 'Checkin Details',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Destination field hanya untuk checkout
              if (_currentTab == 'checkout') ...[
                TextFormField(
                  controller: _destinationController,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Destination Location',
                    hintText: 'Where are you taking these items?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.location_on_outlined),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isSmallScreen ? 12 : 14,
                    ),
                    isDense: isSmallScreen,
                  ),
                ),
                SizedBox(height: 12),
              ],

              // Remarks Field
              TextFormField(
                controller: _remarksController,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: isSmallScreen ? 13 : 14,
                ),
                decoration: InputDecoration(
                  labelText: 'Remarks',
                  hintText: _currentTab == 'checkout'
                      ? 'Purpose of checkout...'
                      : 'Additional notes about the return...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.note_outlined),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isSmallScreen ? 12 : 14,
                  ),
                  isDense: isSmallScreen,
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // PERBAIKAN: Responsive condition button
  Widget _buildConditionButton() {
    final conditionsSet = _itemConditions.length;
    final totalItems = _selectedItems.length;
    final allConditionsSet = conditionsSet == totalItems;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _openConditionPage,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: allConditionsSet
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    allConditionsSet
                        ? Icons.check_circle_outline
                        : Icons.assessment_outlined,
                    color: allConditionsSet
                        ? AppColors.success
                        : AppColors.warning,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set Item Conditions',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        allConditionsSet
                            ? 'All conditions set ✓'
                            : '$conditionsSet of $totalItems conditions set',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: allConditionsSet
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // PERBAIKAN: Fixed bottom action section with responsive design
  Widget _buildBottomActionSection(AssetsState state) {
    final isCheckout = _currentTab == 'checkout';
    final isLoading =
        state is AssetsBulkCheckoutLoading || state is AssetsBulkCheckinLoading;
    final hasSelectedItems = _selectedItems.isNotEmpty;
    final hasDestination = _destinationController.text.trim().isNotEmpty;

    final allConditionsSet = _currentTab == 'checkin'
        ? _selectedItems.every(
            (item) => _itemConditions.containsKey(item.instanceId),
          )
        : true;

    final isEnabled =
        hasSelectedItems &&
        (isCheckout ? hasDestination : allConditionsSet) &&
        !isLoading;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, -1),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selection summary
            if (hasSelectedItems) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedItems.length} item${_selectedItems.length > 1 ? 's' : ''} selected',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_currentTab == 'checkin')
                            Text(
                              allConditionsSet
                                  ? 'All conditions set ✓'
                                  : 'Set conditions required',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: allConditionsSet
                                    ? AppColors.success
                                    : AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
            ],

            // Action buttons
            Row(
              children: [
                if (hasSelectedItems) ...[
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                _selectedItems.clear();
                                _itemConditions.clear();
                              });
                            },
                      icon: Icon(Icons.clear_all, size: 18),
                      label: Text('Clear'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.border),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                ],

                Expanded(
                  flex: hasSelectedItems ? 2 : 1,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEnabled
                          ? (isCheckout ? AppColors.primary : AppColors.success)
                          : AppColors.textSecondary.withOpacity(0.3),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: isEnabled ? 2 : 0,
                    ),
                    onPressed: isEnabled ? _processOperation : null,
                    icon: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            isCheckout ? Icons.logout : Icons.login,
                            size: 20,
                          ),
                    label: Text(
                      _getActionButtonText(
                        isCheckout,
                        isLoading,
                        hasSelectedItems,
                      ),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Help text
            if (!isEnabled) ...[
              SizedBox(height: 8),
              Text(
                _getHelpText(
                  hasSelectedItems,
                  hasDestination,
                  allConditionsSet,
                ),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getActionButtonText(
    bool isCheckout,
    bool isLoading,
    bool hasSelectedItems,
  ) {
    if (isLoading) {
      return 'Processing...';
    }

    if (!hasSelectedItems) {
      return isCheckout
          ? 'Select Items to Checkout'
          : 'Select Items to Checkin';
    }

    final action = isCheckout ? 'Checkout' : 'Checkin';
    final count = _selectedItems.length;

    return '$action $count Item${count > 1 ? 's' : ''}';
  }

  String _getHelpText(
    bool hasSelectedItems,
    bool hasDestination,
    bool allConditionsSet,
  ) {
    if (_currentTab == 'checkout') {
      if (!hasSelectedItems && !hasDestination) {
        return 'Select items and enter destination to proceed';
      } else if (!hasSelectedItems) {
        return 'Please select at least one item';
      } else if (!hasDestination) {
        return 'Please enter destination location';
      }
    } else {
      if (!hasSelectedItems) {
        return 'Please select at least one item to checkin';
      } else if (!allConditionsSet) {
        return 'Please set conditions for all selected items';
      }
    }
    return '';
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading bulk instances...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _currentTab == 'checkout' ? Icons.logout : Icons.login,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Items Available',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _currentTab == 'checkout'
                  ? 'No items are currently available for checkout.\nTry refreshing to see if new items are available.'
                  : 'No items are currently checked out.\nTry refreshing to see if items are available for checkin.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadBulkInstances,
              icon: Icon(Icons.refresh),
              label: Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'good':
        return AppColors.success;
      case 'slightly worn':
        return Colors.lightGreen;
      case 'worn':
        return AppColors.warning;
      case 'damaged':
        return Colors.orange;
      case 'needs repair':
        return AppColors.error;
      case 'missing parts':
        return Colors.red.shade700;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return AppColors.success;
      case 'in use':
      case 'checked out':
        return AppColors.warning;
      case 'missing':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
