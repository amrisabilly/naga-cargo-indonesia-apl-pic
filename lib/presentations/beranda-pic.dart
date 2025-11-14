import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class BerandaPicScreen extends StatefulWidget {
  const BerandaPicScreen({super.key});

  @override
  State<BerandaPicScreen> createState() => _BerandaPicScreenState();
}

class _BerandaPicScreenState extends State<BerandaPicScreen> {
  final TextEditingController _alamatController = TextEditingController();
  bool _hasScanResult = false;
  String _scannedCode = '';
  String? _bastImageUrl;
  bool _isLoading = false;

  Future<void> _scanBast() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanBastScreen()),
    );

    if (result != null && result is String) {
      setState(() {
        _hasScanResult = true;
        _scannedCode = result;
      });
    }
  }

  void _retakeBast() {
    setState(() {
      _hasScanResult = false;
      _scannedCode = '';
    });
  }

  void _submitData() {
    if (_alamatController.text.trim().isEmpty) {
      return;
    }
    if (!_hasScanResult) {
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 15),
                Text(
                  'Menyimpan data...',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      setState(() {
        _hasScanResult = false;
        _scannedCode = '';
        _alamatController.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // Header dengan gradient - lebih kompak
          Container(
            height: screenHeight * 0.17, // Dikurangi dari 0.3 ke 0.25
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header info - lebih kompak
                    GestureDetector(
                      onTap: () {
                        // Navigate using go_router
                        context.go('/profile_pic');
                      },
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF4A90E2),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat Datang,',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'PIC Naga Cargo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content dengan keyboard handling
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bottomInset =
                        MediaQuery.of(context).viewInsets.bottom;
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        15,
                        20,
                        120 +
                            bottomInset, // <-- Tambahkan padding bawah sesuai keyboard
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Scan BAST Section - lebih kompak
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(
                              14,
                            ), // Dikurangi dari 16
                            decoration: BoxDecoration(
                              color:
                                  _hasScanResult
                                      ? Colors.blue[50]
                                      : Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tombol Scan BAST
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.qr_code_scanner,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Scan BAST',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A90E2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: _scanBast,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Input manual kode BAST
                                const Text(
                                  'Atau masukkan kode BAST secara manual:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  onChanged: (val) {
                                    setState(() {
                                      _scannedCode = val;
                                      _hasScanResult = val.trim().isNotEmpty;
                                    });
                                  },
                                  controller: TextEditingController(
                                    text: _scannedCode,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Masukkan kode BAST...',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF4A90E2),
                                      ), // biru
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF4A90E2),
                                      ), // biru
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF357ABD),
                                        width: 2,
                                      ), // biru tua saat fokus
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                                if (_hasScanResult) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF357ABD), // biru tua
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Kode BAST terisi',
                                        style: TextStyle(
                                          color: Color(0xFF357ABD), // biru tua
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue[200]!, // biru
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Kode BAST:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _scannedCode,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Alamat Tujuan Input
                          const Text(
                            'Nama Tujuan',
                            style: TextStyle(
                              fontSize: 15, // Dikurangi dari 16
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: TextField(
                              controller: _alamatController,
                              onChanged: (value) {
                                setState(() {}); // Update button state
                              },
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan nama tujuan lengkap...',
                                hintStyle: TextStyle(fontSize: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.all(
                                  14,
                                ), // Dikurangi dari 16
                              ),
                            ),
                          ),

                          const SizedBox(height: 20), // Space untuk scroll
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Sheet untuk action buttons
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scan/Retake Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : (_hasScanResult ? _retakeBast : _scanBast),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _hasScanResult
                            ? Colors.orange
                            : const Color(0xFF4A90E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _hasScanResult ? Icons.refresh : Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 18, // Dikurangi dari 20
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hasScanResult ? 'Scan Ulang BAST' : 'Scan BAST',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14, // Dikurangi dari 15
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_hasScanResult &&
                              _alamatController.text.trim().isNotEmpty)
                          ? _submitData
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send,
                        color:
                            (_hasScanResult &&
                                    _alamatController.text.trim().isNotEmpty)
                                ? Colors.white
                                : Colors.grey[600],
                        size: 18, // Dikurangi dari 20
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kirim Data',
                        style: TextStyle(
                          color:
                              (_hasScanResult &&
                                      _alamatController.text.trim().isNotEmpty)
                                  ? Colors.white
                                  : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 14, // Dikurangi dari 15
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _alamatController.dispose();
    super.dispose();
  }
}

// Halaman scan BAST menggunakan kamera
class ScanBastScreen extends StatefulWidget {
  const ScanBastScreen({super.key});

  @override
  State<ScanBastScreen> createState() => _ScanBastScreenState();
}

class _ScanBastScreenState extends State<ScanBastScreen> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Kode BAST'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(),
            onDetect: (capture) {
              if (!_isScanned && capture.barcodes.isNotEmpty) {
                final String? code = capture.barcodes.first.rawValue;
                if (code != null) {
                  setState(() {
                    _isScanned = true;
                  });
                  Navigator.pop(context, code);
                }
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Arahkan kamera ke kode BAST',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Profile PIC Screen placeholder
