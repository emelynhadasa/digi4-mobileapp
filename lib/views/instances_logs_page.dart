// Anda bisa menempatkan file ini di, contohnya, pages/instances/instance_logs_page.dart

import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:flutter/material.dart';

class InstanceLogsPage extends StatefulWidget {
  // Menerima instanceId untuk mengetahui log mana yang harus ditampilkan.
  final String instanceId;

  const InstanceLogsPage({super.key, required this.instanceId});

  @override
  State<InstanceLogsPage> createState() => _InstanceLogsPageState();
}

class _InstanceLogsPageState extends State<InstanceLogsPage> {
  // Data dummy untuk daftar log
  final List<Map<String, dynamic>> dummyLogs = [
    {
      'userType': 'Operator',
      'dateTime': '2024-05-24 14:30:15',
      'details': 'Checked out from Warehouse A',
      'remarks': 'For project "Alpha Site"',
    },
    {
      'userType': 'System',
      'dateTime': '2024-05-22 09:00:00',
      'details': 'Status changed to "In Use"',
      'remarks': '',
    },
    {
      'userType': 'Operator',
      'dateTime': '2024-05-20 11:15:45',
      'details': 'Checked in to Warehouse B',
      'remarks': 'Project "Alpha Site" completed.',
    },
    {
      'userType': 'Admin',
      'dateTime': '2024-05-18 16:00:20',
      'details': 'Repair requested',
      'remarks': 'Minor scratches on the casing.',
    },
    {
      'userType': 'System',
      'dateTime': '2024-05-18 16:01:00',
      'details': 'Status changed to "In Repair"',
      'remarks': '',
    },
    {
      'userType': 'Admin',
      'dateTime': '2024-05-15 10:05:00',
      'details': 'Instance created',
      'remarks': 'Initial stock.',
    },
  ];

  // Method untuk handle refresh (bisa diisi logic BLoC nanti)
  Future<void> _onRefresh() async {
    print("Refreshing logs for instance: ${widget.instanceId}");
    await Future.delayed(Duration(seconds: 1));
  }

  // Helper untuk mendapatkan ikon & warna berdasarkan detail log
  Map<String, dynamic> _getLogIcon(String details) {
    String lowerDetails = details.toLowerCase();
    if (lowerDetails.contains('checkout') || lowerDetails.contains('out')) {
      return {'icon': Icons.arrow_upward_rounded, 'color': AppColors.error};
    }
    if (lowerDetails.contains('checkin') || lowerDetails.contains('in')) {
      return {'icon': Icons.arrow_downward_rounded, 'color': AppColors.success};
    }
    if (lowerDetails.contains('repair')) {
      return {'icon': Icons.build_rounded, 'color': AppColors.warning};
    }
    if (lowerDetails.contains('created')) {
      return {
        'icon': Icons.add_circle_outline_rounded,
        'color': AppColors.primary,
      };
    }
    return {
      'icon': Icons.info_outline_rounded,
      'color': AppColors.textSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instance Logs',
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
            ),
            Text(
              widget.instanceId,
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
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: dummyLogs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final log = dummyLogs[index];
            return _buildLogItem(log);
          },
        ),
      ),
    );
  }

  // Widget untuk membangun setiap kartu item log
  Widget _buildLogItem(Map<String, dynamic> log) {
    final iconInfo = _getLogIcon(log['details']);
    final bool hasRemarks = log['remarks'] != null && log['remarks'].isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom Kiri: Ikon
          CircleAvatar(
            radius: 20,
            backgroundColor: (iconInfo['color'] as Color).withOpacity(0.1),
            child: Icon(
              iconInfo['icon'] as IconData,
              color: iconInfo['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Kolom Kanan: Detail Log
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas: Detail Utama dan Waktu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        log['details'],
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      log['dateTime'],
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // User Type
                Text.rich(
                  TextSpan(
                    text: 'By: ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: log['userType'],
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Remarks (jika ada)
                if (hasRemarks) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remarks:',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log['remarks'],
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
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
    );
  }
}
