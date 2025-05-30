import 'dart:convert';
import 'package:digi4_mobile/models/repair_request_model.dart';
import 'package:digi4_mobile/services/repair_service.dart';
import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';

class RepairDetailPage extends StatefulWidget {
  final RepairRequestModel repairRequest;

  const RepairDetailPage({super.key, required this.repairRequest});

  @override
  _RepairDetailPageState createState() => _RepairDetailPageState();
}

class _RepairDetailPageState extends State<RepairDetailPage> {
  late String _status;
  late DateTime _lastUpdated;
  final RepairService _repairService = RepairService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _status = widget.repairRequest.status;
    _lastUpdated = widget.repairRequest.updatedAt;
    print('Initial status from widget: ${widget.repairRequest.status}');
    print('Initial _status in initState: $_status');
  }

  void _updateStatus(String newStatus) {
    setState(() {
      _status = newStatus;
      _lastUpdated = DateTime.now();
    });

    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated to $_status'),
        backgroundColor: _getStatusColor(_status),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _startRepairRequest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _repairService.startRepairRequest(
        widget.repairRequest.repairRequestId,
      );

      _updateStatus('In Progress');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Repair request started successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start repair: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsUnfixable() async {
    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(
      'Mark as Unfixable',
      'Are you sure you want to mark this repair as unfixable? This action cannot be undone.',
      'Mark Unfixable',
      AppColors.error,
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _repairService.markRepairAsUnfixable(
        widget.repairRequest.repairRequestId,
      );

      _updateStatus('Unfixable');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Repair marked as unfixable'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as unfixable: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _finishRepairRequest() async {
    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(
      'Finish Repair',
      'Are you sure you want to mark this repair as finished? This will complete the repair request.',
      'Finish Repair',
      AppColors.success,
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _repairService.finishRepairRequest(
        widget.repairRequest.repairRequestId,
      );

      _updateStatus('Completed');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Repair completed successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to finish repair: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _showConfirmationDialog(
    String title,
    String message,
    String confirmButtonText,
    Color confirmButtonColor,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmButtonColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmButtonText),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Color _getStatusColor(String status) {
    final normalizedStatus = _normalizeStatus(status);
    switch (normalizedStatus) {
      case 'pending':
      case 'requested':
        return AppColors.warning;
      case 'inprogress': // API mengirim "In Progress"
        return AppColors.info;
      case 'completed':
      case 'done':
        return AppColors.success;
      case 'cancelled':
      case 'rejected':
        return AppColors.error;
      case 'unfixable':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // PERBAIKAN: Normalisasi status untuk konsistensi
  String _normalizeStatus(String status) {
    // Bersihkan dari quotes, trim whitespace, lowercase, dan hilangkan spasi
    return status
        .replaceAll('"', '')
        .replaceAll("'", "")
        .trim()
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('_', '');
  }

  // PERBAIKAN: Method untuk debugging status
  void _debugStatusConditions() {
    final normalizedStatus = _normalizeStatus(_status);
    print('=== DEBUG STATUS CONDITIONS ===');
    print('Original status: "$_status"');
    print('Status trimmed: "${_status.trim()}"');
    print(
      'Status with quotes removed: "${_status.replaceAll('"', '').replaceAll("'", "")}"',
    );
    print('Normalized status: "$normalizedStatus"');
    print('Normalized length: ${normalizedStatus.length}');
    print('Expected values for comparison:');
    print('  - "requested" length: ${"requested".length}');
    print('  - "inprogress" length: ${"inprogress".length}');
    print('Character comparison:');
    print(
      '  - normalizedStatus == "requested": ${normalizedStatus == "requested"}',
    );
    print(
      '  - normalizedStatus == "inprogress": ${normalizedStatus == "inprogress"}',
    );
    print(
      '  - normalizedStatus == "completed": ${normalizedStatus == "completed"}',
    );
    print(
      '  - normalizedStatus == "unfixable": ${normalizedStatus == "unfixable"}',
    );
    print('isRequested: ${_isRequested()}');
    print('isInProgress: ${_isInProgress()}');
    print('isCompleted: ${_isCompleted()}');
    print('isUnfixable: ${_isUnfixable()}');
    print('================================');
  }

  // PERBAIKAN: Method terpisah untuk setiap kondisi status sesuai format API
  bool _isRequested() {
    final normalizedStatus = _normalizeStatus(_status);
    return normalizedStatus == 'requested' || normalizedStatus == 'pending';
  }

  bool _isInProgress() {
    final normalizedStatus = _normalizeStatus(_status);
    // API mengirim "In Progress" jadi setelah normalisasi jadi "inprogress"
    return normalizedStatus == 'inprogress';
  }

  bool _isCompleted() {
    final normalizedStatus = _normalizeStatus(_status);
    return normalizedStatus == 'completed' ||
        normalizedStatus == 'done' ||
        normalizedStatus == 'finished';
  }

  bool _isUnfixable() {
    final normalizedStatus = _normalizeStatus(_status);
    return normalizedStatus == 'unfixable';
  }

  @override
  Widget build(BuildContext context) {
    print('=== BUILD METHOD DEBUG ===');
    print('Raw status from widget: "${widget.repairRequest.status}"');
    print('Current _status: "$_status"');
    print('Status type: ${_status.runtimeType}');
    print('Status length: ${_status.length}');
    print(
      'Status characters: ${_status.split('').map((c) => c.codeUnitAt(0)).toList()}',
    );

    // DEBUG: Print kondisi status
    _debugStatusConditions();

    final isRequested = _isRequested();
    final isInProgress = _isInProgress();
    final isCompleted = _isCompleted();
    final isUnfixable = _isUnfixable();

    print('Final conditions:');
    print('  - isRequested: $isRequested');
    print('  - isInProgress: $isInProgress');
    print('  - isCompleted: $isCompleted');
    print('  - isUnfixable: $isUnfixable');
    print('========================');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          'Repair Details',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
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
                    'Updating repair status...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  _buildStatusBadge(),
                  SizedBox(height: 16),

                  // Image Section (if available)
                  if (widget.repairRequest.repairReqImage != null ||
                      widget.repairRequest.repairImageBase64 != null)
                    _buildImageSection(),

                  // Details Card
                  _buildDetailsCard(),
                  SizedBox(height: 16),

                  // Action Buttons
                  _buildActionButtons(
                    isRequested,
                    isInProgress,
                    isCompleted,
                    isUnfixable,
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = _getStatusColor(_status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(_status), color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _status,
                  style: AppTextStyles.h4.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    final normalizedStatus = _normalizeStatus(status);
    switch (normalizedStatus) {
      case 'pending':
      case 'requested':
        return Icons.pending_outlined;
      case 'inprogress': // API mengirim "In Progress"
        return Icons.engineering_outlined;
      case 'completed':
      case 'done':
        return Icons.check_circle_outline;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel_outlined;
      case 'unfixable':
        return Icons.build_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.background,
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildRepairImage(),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRepairImage() {
    // Handle base64 image
    if (widget.repairRequest.repairImageBase64 != null &&
        widget.repairRequest.repairImageBase64.toString().isNotEmpty) {
      try {
        final bytes = base64Decode(
          widget.repairRequest.repairImageBase64.toString(),
        );
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildImagePlaceholder(),
        );
      } catch (e) {
        return _buildImagePlaceholder();
      }
    }

    // Handle URL image
    if (widget.repairRequest.repairReqImage != null &&
        widget.repairRequest.repairReqImage.toString().isNotEmpty) {
      return Image.network(
        widget.repairRequest.repairReqImage.toString(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: 8),
            Text(
              'No Image Available',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repair Information',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),

          _buildDetailRow(
            'Request ID',
            widget.repairRequest.repairRequestId.toString(),
          ),
          _buildDetailRow('Instance', widget.repairRequest.instanceDisplay),
          _buildDetailRow('KPK', widget.repairRequest.kpk),
          _buildDetailRow('Submitted By', widget.repairRequest.submittedByName),
          _buildDetailRow('Last Updated', _formatDateTime(_lastUpdated)),

          SizedBox(height: 16),

          // Remarks Section
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Remarks',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  widget.repairRequest.remarks.isNotEmpty
                      ? widget.repairRequest.remarks
                      : 'No remarks provided',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: widget.repairRequest.remarks.isNotEmpty
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontStyle: widget.repairRequest.remarks.isNotEmpty
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PERBAIKAN: Simplifikasi logika tombol dengan debugging yang lebih baik
  Widget _buildActionButtons(
    bool isRequested,
    bool isInProgress,
    bool isCompleted,
    bool isUnfixable,
  ) {
    print('=== BUTTON BUILD DEBUG ===');
    print('Status: $_status');
    print('isRequested: $isRequested');
    print('isInProgress: $isInProgress');
    print('isCompleted: $isCompleted');
    print('isUnfixable: $isUnfixable');
    print('========================');

    // Completed State
    if (isCompleted) {
      return _buildCompletedMessage();
    }

    // Unfixable State
    if (isUnfixable) {
      return _buildUnfixableMessage();
    }

    // Action buttons untuk status aktif
    return Column(
      children: [
        // Start Request Button (when status is Requested/Pending)
        if (isRequested) _buildStartButton(),

        // In Progress Actions (Unfixable and Finish buttons)
        if (isInProgress) _buildInProgressButtons(),

        // DEBUGGING: Jika tidak ada kondisi yang terpenuhi
        if (!isRequested && !isInProgress && !isCompleted && !isUnfixable)
          _buildDebugMessage(),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        icon: Icon(Icons.play_arrow_outlined),
        label: Text(
          'Start Repair',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        onPressed: _startRepairRequest,
      ),
    );
  }

  Widget _buildInProgressButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            icon: Icon(Icons.build_outlined),
            label: Text(
              'Unfixable',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: _markAsUnfixable,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            icon: Icon(Icons.check_circle_outline),
            label: Text(
              'Finish',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: _finishRepairRequest,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success),
          SizedBox(width: 12),
          Text(
            'This repair request has been completed',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnfixableMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.build_outlined, color: AppColors.error),
          SizedBox(width: 12),
          Text(
            'This repair request has been marked as unfixable',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // DEBUGGING: Widget untuk debugging ketika status tidak dikenali
  Widget _buildDebugMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'DEBUG: Status tidak dikenali',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Status asli: "${widget.repairRequest.status}"',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.orange),
          ),
          Text(
            'Status saat ini: "$_status"',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.orange),
          ),
          Text(
            'Status normalized: "${_normalizeStatus(_status)}"',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.orange),
          ),
          SizedBox(height: 8),
          Text(
            'Kondisi boolean:',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '• isRequested: ${_isRequested()}',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.orange),
          ),
          Text(
            '• isInProgress: ${_isInProgress()}',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.orange),
          ),
          Text(
            '• isCompleted: ${_isCompleted()}',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.orange),
          ),
          Text(
            '• isUnfixable: ${_isUnfixable()}',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
