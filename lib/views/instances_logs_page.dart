// lib/views/instances_logs_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/instance/instance_logs_bloc.dart';   // Bloc, State, Event
import 'package:digi4_mobile/models/instance_model.dart';                  // Model for each log
import '../styles/color.dart';
import '../styles/shared_typography.dart';

class InstanceLogsPage extends StatefulWidget {
  final int instanceId;
  const InstanceLogsPage({super.key, required this.instanceId});

  @override
  State<InstanceLogsPage> createState() => _InstanceLogsPageState();
}

class _InstanceLogsPageState extends State<InstanceLogsPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch event saat halaman dibuka
    context.read<InstanceLogsBloc>().add(
      InstanceLogsRequested(instanceId: widget.instanceId),
    );
  }

  Future<void> _onRefresh() async {
    // Memanggil ulang fetch logs saat pull-to-refresh
    context.read<InstanceLogsBloc>().add(
      InstanceLogsRequested(instanceId: widget.instanceId),
    );
  }

  // Widget untuk menampilkan state error
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Logs',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk setiap item InstanceLog
  Widget _buildLogItemFromInstanceLog(InstanceLog log) {
    final iconInfo = _getLogIcon(log.details);
    final dateTime = log.transactionDate.toLocal().toString().split('.')[0];

    final bool hasRemarks = log.remarks.isNotEmpty;

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
          // Ikon berdasarkan jenis detail
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
                        log.details,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateTime,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Nama User atau System
                Text.rich(
                  TextSpan(
                    text: 'By: ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: log.name,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tampilkan remarks jika ada
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
                          log.remarks,
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

  // Helper untuk memilih ikon & warna berdasarkan isi detail log
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
              widget.instanceId.toString(),
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
        child: BlocBuilder<InstanceLogsBloc, InstanceLogsState>(
          builder: (context, state) {
            if (state is InstanceLogsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is InstanceLogsFailure) {
              return _buildErrorState(state.message);
            } else if (state is InstanceLogsLoaded) {
              final logs = state.logs; // List<InstanceLog>
              if (logs.isEmpty) {
                return Center(
                  child: Text(
                    'No logs available.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildLogItemFromInstanceLog(logs[index]);
                },
              );
            }
            // Initial atau state selain Loading / Loaded / Failure
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
