// file: pages/scan/scan_page.dart

import 'package:digi4_mobile/styles/color.dart';
import 'package:digi4_mobile/styles/shared_typography.dart';
import 'package:digi4_mobile/views/instances_detail_page.dart';
import 'package:digi4_mobile/config/constant.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:digi4_mobile/models/assets_model.dart';
import 'package:http/http.dart' as http;

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // Controller tetap dibutuhkan untuk manajemen dasar kamera
  final MobileScannerController _scannerController = MobileScannerController();

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  // Flag untuk mencegah pemindaian berulang saat navigasi
  bool _isProcessing = false;

  // Data dummy untuk simulasi pencarian
  final List<Map<String, dynamic>> dummyInstances = [
    {
      'instanceId': 'RE-AV-GOOD-01',
      'assetId': 'AST-HAMMER-01',
      'qrCodeUrl': '...',
      'type': 'Reusable',
      'status': 'Available',
      'condition': 'Good',
      'location': 'Warehouse A',
      'warrantyExpiryDate': '2027-01-01',
      'serialNumber': 'SN-HM-001',
      'qty': 1,
      'plant': 'Factory A',
      'shelf': 'Shelf 01',
      'restockThreshold': 1,
      'shelfLife': 'N/A',
    },
    {
      'instanceId': 'RE-AV-DMGD-02',
      'assetId': 'AST-DRILL-02',
      'qrCodeUrl': '...',
      'type': 'Reusable',
      'status': 'Available',
      'condition': 'Damaged',
      'location': 'Warehouse A',
      'warrantyExpiryDate': '2025-08-15',
      'serialNumber': 'SN-DR-002',
      'qty': 1,
      'plant': 'Factory B',
      'shelf': 'Shelf 02',
      'restockThreshold': 1,
      'shelfLife': 'N/A',
    },
    {
      'instanceId': 'CO-TAPE-05',
      'assetId': 'AST-DBLT-01',
      'qrCodeUrl': '...',
      'type': 'Consumable',
      'status': 'Available',
      'condition': 'New',
      'location': 'Warehouse C',
      'warrantyExpiryDate': 'N/A',
      'serialNumber': 'N/A',
      'qty': 200,
      'plant': 'Warehouse C',
      'shelf': 'Shelf 03',
      'restockThreshold': 50,
      'shelfLife': '2 Years',
    },
  ];

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  // Fungsi yang dipanggil setiap kali QR code terdeteksi
  void _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final barcodes = capture.barcodes;
      if (barcodes.isEmpty || barcodes.first.rawValue == null) {
        // Jangan lupa reset _isProcessing kalau ga lanjut
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      final scannedValue = barcodes.first.rawValue!;
      print('QR Code terdeteksi: $scannedValue');

      final parts = scannedValue.split('|');
      if (parts.length < 3 || !parts[2].startsWith('INS')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Format QR tidak sesuai'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isProcessing = false);
        }
        return;
      }

      final instanceIdStr = parts[2].substring(3);
      final instanceId = int.tryParse(instanceIdStr);

      if (instanceId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Format INS ID tidak valid'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isProcessing = false);
        }
        return;
      }

      print('Stopping scanner...');
      await _scannerController.stop();
      print('Scanner stopped.');

      final url = Uri.parse("${Constant.baseUrl}/instances/instance/$instanceId");
      print("Request URL: $url");

      try {
        final response = await http.get(url).timeout(const Duration(seconds: 8)); // kasi timeout 8 detik

        if (response.statusCode == 200) {
          final Map<String, dynamic> rawInstance = json.decode(response.body);

          // 🔧 Normalisasi semua key ke camelCase (ex: AssetId → assetId)
          final Map<String, dynamic> instance = {};
          for (final entry in rawInstance.entries) {
            final String camelKey = entry.key[0].toLowerCase() + entry.key.substring(1);
            final value = entry.value;
            instance[camelKey] = value is Map || value is List ? value : value?.toString();
          }
          print('INSTANCE NORMALIZED:');
          instance.forEach((k, v) => print('$k: ${v.runtimeType} = $v'));

          // Tetap lakukan ini untuk si qrCodeUrl
          final qrRawData = instance['qrCodeUrl'];
          instance['qrCodeUrl'] = qrRawData != null && qrRawData != ''
              ? 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$qrRawData'
              : '';

          if (!mounted) return;

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InstancesDetailPage(instance: instance),
            ),
          );
        } else {
          throw Exception('Instance tidak ditemukan (status code: ${response.statusCode})');
        }
      } on TimeoutException catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Request timeout, coba lagi.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengambil data instance: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      print('Error general di _handleDetection: $e');
    } finally {
      try {
        print('Restarting scanner...');
        await _scannerController.start();
        print('Scanner restarted.');
      } catch (e) {
        print('Gagal restart scanner: $e');
      }

      // Delay supaya scan gak langsung nyala terus-terusan
      await Future.delayed(const Duration(milliseconds: 700));

      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Instance QR Code'),
        backgroundColor: Colors.black,
        // Properti 'actions' telah dihapus dari sini
      ),
      body: Stack(
        children: [
          // Layer 1: Tampilan Kamera
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleDetection,
          ),

          // Layer 2: Overlay UI (bingkai, teks, dll)
          _buildScannerOverlay(),

          // Layer 3: Loading indicator saat memproses
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget untuk membuat bingkai dan teks overlay
  Widget _buildScannerOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Text(
            'Position the QR code inside the frame',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              shadows: [const Shadow(blurRadius: 4.0, color: Colors.black54)],
            ),
          ),
          const SizedBox(height: 16),
          // Bingkai pemindai
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
