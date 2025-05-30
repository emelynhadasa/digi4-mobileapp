import 'package:digi4_mobile/models/assets_model.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';

class BulkConditionPage extends StatefulWidget {
  final List<BulkItems> selectedItems;
  final Map<int, String> initialConditions;

  const BulkConditionPage({
    super.key,
    required this.selectedItems,
    required this.initialConditions,
  });

  @override
  _BulkConditionPageState createState() => _BulkConditionPageState();
}

class _BulkConditionPageState extends State<BulkConditionPage> {
  late Map<int, String> _itemConditions;
  bool _hasUnsavedChanges = false;

  final List<String> _conditionOptions = [
    'Good',
    'Slightly Worn',
    'Worn',
    'Damaged',
    'Needs Repair',
    'Missing Parts',
  ];

  final List<Map<String, dynamic>> _conditionInfo = [
    {
      'condition': 'Good',
      'description': 'Item is in excellent working condition',
      'icon': Icons.check_circle_outline,
    },
    {
      'condition': 'Slightly Worn',
      'description': 'Minor wear but fully functional',
      'icon': Icons.radio_button_unchecked,
    },
    {
      'condition': 'Worn',
      'description': 'Visible wear but still usable',
      'icon': Icons.warning_amber_outlined,
    },
    {
      'condition': 'Damaged',
      'description': 'Has damage but may still function',
      'icon': Icons.error_outline,
    },
    {
      'condition': 'Needs Repair',
      'description': 'Requires repair before use',
      'icon': Icons.build_outlined,
    },
    {
      'condition': 'Missing Parts',
      'description': 'Missing components or parts',
      'icon': Icons.inventory_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _itemConditions = Map.from(widget.initialConditions);
    
    // Set default conditions for items without conditions
    for (var item in widget.selectedItems) {
      if (item.instanceId != null && !_itemConditions.containsKey(item.instanceId)) {
        _itemConditions[item.instanceId!] = 'Good';
      }
    }
  }

  void _updateItemCondition(int instanceId, String condition) {
    setState(() {
      _itemConditions[instanceId] = condition;
      _hasUnsavedChanges = true;
    });
  }

  void _setBulkCondition(String condition) {
    setState(() {
      for (var item in widget.selectedItems) {
        if (item.instanceId != null) {
          _itemConditions[item.instanceId!] = condition;
        }
      }
      _hasUnsavedChanges = true;
    });

    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Set all items to "$condition"'),
        backgroundColor: _getConditionColor(condition),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveConditions() {
    Navigator.pop(context, _itemConditions);
  }

  void _resetConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Conditions'),
        content: Text('Are you sure you want to reset all conditions to "Good"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                for (var item in widget.selectedItems) {
                  if (item.instanceId != null) {
                    _itemConditions[item.instanceId!] = 'Good';
                  }
                }
                _hasUnsavedChanges = true;
              });
            },
            child: Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsaved Changes'),
        content: Text('You have unsaved changes. Do you want to save them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Discard'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              _saveConditions();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Map<String, int> _getConditionSummary() {
    Map<String, int> summary = {};
    for (String condition in _conditionOptions) {
      summary[condition] = 0;
    }

    for (var condition in _itemConditions.values) {
      summary[condition] = (summary[condition] ?? 0) + 1;
    }

    return summary;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Set Item Conditions',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.textSecondary),
              onPressed: _resetConditions,
              tooltip: 'Reset all to Good',
            ),
            TextButton(
              onPressed: _saveConditions,
              child: Text(
                'Save',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Header with bulk actions and summary
            _buildHeaderSection(),
            
            // Summary stats
            _buildSummarySection(),
            
            // Items list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.selectedItems.length,
                itemBuilder: (context, index) {
                  final item = widget.selectedItems[index];
                  return _buildConditionCard(item, index);
                },
              ),
            ),
            
            // Bottom action
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.assessment_outlined,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Conditions',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.selectedItems.length} items selected for checkin',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasUnsavedChanges)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 12,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Modified',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          
          // Bulk condition selector
          Text(
            'Quick set all items to:',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _conditionOptions.map((condition) {
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getConditionColor(condition),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          condition,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    onSelected: (_) => _setBulkCondition(condition),
                    backgroundColor: Colors.white,
                    selectedColor: _getConditionColor(condition).withOpacity(0.2),
                    checkmarkColor: _getConditionColor(condition),
                    side: BorderSide(color: _getConditionColor(condition)),
                    selected: false,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final summary = _getConditionSummary();
    final hasMultipleConditions = summary.values.where((count) => count > 0).length > 1;

    if (!hasMultipleConditions) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Condition Summary',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: summary.entries
                .where((entry) => entry.value > 0)
                .map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getConditionColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${entry.value} ${entry.key}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionCard(BulkItems item, int index) {
    if (item.instanceId == null) return SizedBox.shrink();
    
    final currentCondition = _itemConditions[item.instanceId] ?? 'Good';
    final conditionInfo = _conditionInfo.firstWhere(
      (info) => info['condition'] == currentCondition,
      orElse: () => _conditionInfo.first,
    );
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            radius: 18,
            child: Text(
              '${index + 1}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instance ${item.instanceId}',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (item.assetName != null) ...[
                SizedBox(height: 2),
                Text(
                  item.assetName!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.location != null) ...[
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.location!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 8),
              // Current condition badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getConditionColor(currentCondition).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getConditionColor(currentCondition).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      conditionInfo['icon'],
                      size: 16,
                      color: _getConditionColor(currentCondition),
                    ),
                    SizedBox(width: 6),
                    Text(
                      currentCondition,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getConditionColor(currentCondition),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            // Condition description
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      conditionInfo['description'],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            
            // Condition options
            Text(
              'Select condition:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _conditionOptions.map((condition) {
                final isSelected = currentCondition == condition;
                final info = _conditionInfo.firstWhere(
                  (info) => info['condition'] == condition,
                  orElse: () => _conditionInfo.first,
                );
                
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        info['icon'],
                        size: 14,
                        color: isSelected
                            ? _getConditionColor(condition)
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        condition,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => _updateItemCondition(item.instanceId!, condition),
                  backgroundColor: Colors.white,
                  selectedColor: _getConditionColor(condition).withOpacity(0.2),
                  checkmarkColor: _getConditionColor(condition),
                  side: BorderSide(
                    color: isSelected
                        ? _getConditionColor(condition)
                        : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
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
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_hasUnsavedChanges) ...[
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have unsaved changes. Don\'t forget to save!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (await _onWillPop()) {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(Icons.close, size: 18),
                    label: Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.border),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _saveConditions,
                    icon: Icon(Icons.check, size: 18),
                    label: Text('Save Conditions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
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
}