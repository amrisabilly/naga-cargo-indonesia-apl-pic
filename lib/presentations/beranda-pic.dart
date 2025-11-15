import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/loginController.dart';
import '../controller/orderController.dart';

class BerandaPicScreen extends StatefulWidget {
  const BerandaPicScreen({super.key});

  @override
  State<BerandaPicScreen> createState() => _BerandaPicScreenState();
}

class _BerandaPicScreenState extends State<BerandaPicScreen> {
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _awbController = TextEditingController();
  bool _hasScanResult = false;
  String _scannedCode = '';

  @override
  void initState() {
    super.initState();
    print('[DEBUG] BerandaPicScreen initState dipanggil');
  }

  Future<void> _scanBast() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanBastScreen()),
    );

    if (result != null && result is String) {
      print('[DEBUG] Scan result: $result');
      setState(() {
        _hasScanResult = true;
        _scannedCode = result;
        _awbController.text = result;
      });
    }
  }

  void _retakeBast() {
    print('[DEBUG] Retake BAST');
    setState(() {
      _hasScanResult = false;
      _scannedCode = '';
      _awbController.clear();
    });
  }

  Future<void> _submitData() async {
    print('[DEBUG] === SUBMIT DATA DIMULAI ===');
    print('[DEBUG] AWB: $_scannedCode');
    print('[DEBUG] Tujuan: ${_alamatController.text.trim()}');
    print('[DEBUG] ID PIC: ${Provider.of<LoginController>(context, listen: false).userData?['id_user']}');
    print('[DEBUG] isLoading: ${Provider.of<OrderController>(context, listen: false).isLoading}');

    // Validasi input
    if (_alamatController.text.trim().isEmpty) {
      print('[DEBUG] ERROR: Tujuan kosong');
      _showErrorDialog('Nama tujuan tidak boleh kosong');
      return;
    }

    if (!_hasScanResult) {
      print('[DEBUG] ERROR: Kode BAST kosong');
      _showErrorDialog('Kode BAST harus diisi');
      return;
    }

    // Ambil data dari controllers
    final orderController = Provider.of<OrderController>(context, listen: false);
    final loginController = Provider.of<LoginController>(context, listen: false);

    final userData = loginController.userData;
    
    print('[DEBUG] userData: $userData');

    if (userData == null) {
      print('[DEBUG] ERROR: userData NULL');
      _showErrorDialog('Sesi login tidak valid. Silakan login kembali.');
      return;
    }

    final idPic = userData['id_user'] as int;
    final namaPic = userData['nama'] as String;
    print('[DEBUG] ID PIC: $idPic, Nama: $namaPic');

    // Show loading dialog
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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

    // Submit order ke API
    print('[DEBUG] Memanggil orderController.submitOrder...');
    print('[DEBUG] Data: AWB=$_scannedCode, ID=$idPic, Tujuan=${_alamatController.text.trim()}');
    
    final success = await orderController.submitOrder(
      awb: _scannedCode,
      idPic: idPic,
      tujuan: _alamatController.text.trim(),
    );

    print('[DEBUG] Submit result: $success');

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (success) {
      print('[DEBUG] ✓ Order berhasil dikirim');
      _showSuccessDialog(orderController.successMessage);

      // Reset form setelah berhasil
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _hasScanResult = false;
            _scannedCode = '';
            _awbController.clear();
            _alamatController.clear();
          });
          print('[DEBUG] Form direset');
        }
      });
    } else {
      print('[DEBUG] ✗ Order gagal: ${orderController.errorMessage}');
      _showErrorDialog(orderController.errorMessage);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            const SizedBox(width: 10),
            const Text('Berhasil', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600], size: 28),
            const SizedBox(width: 10),
            const Text('Gagal', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<LoginController>(
      builder: (context, loginController, _) {
        print('[DEBUG] Build BerandaPicScreen - userData: ${loginController.userData}');

        final userData = loginController.userData;

        // Jika userData belum tersedia
        if (userData == null) {
          print('[DEBUG] userData NULL - redirect ke login');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && context.mounted) {
              context.go('/login');
            }
          });
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data pengguna...'),
                ],
              ),
            ),
          );
        }

        final namaPic = userData['nama'] ?? 'PIC Naga Cargo';
        final daerah = loginController.namaDaerah ?? 'Tidak diketahui';

        print('[DEBUG] User ditemukan: $namaPic, Daerah: $daerah');

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              // Header dengan gradient
              Container(
                height: screenHeight * 0.17,
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
                        GestureDetector(
                          onTap: () {
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Selamat Datang,',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      namaPic,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
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

              // Content
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
                            120 + bottomInset,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Scan BAST Section
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                          style:
                                              TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF4A90E2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: _scanBast,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
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
                                      controller: _awbController,
                                      onChanged: (value) {
                                        setState(() {
                                          _scannedCode = value;
                                          _hasScanResult =
                                              value.trim().isNotEmpty;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Masukkan kode BAST...',
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xFF4A90E2),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xFF4A90E2),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xFF357ABD),
                                            width: 2,
                                          ),
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
                                        children: const [
                                          Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF357ABD),
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Kode BAST terisi',
                                            style: TextStyle(
                                              color: Color(0xFF357ABD),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.blue[200]!,
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

                              // Nama Tujuan Input
                              const Text(
                                'Nama Tujuan',
                                style: TextStyle(
                                  fontSize: 15,
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
                                    setState(() {});
                                  },
                                  maxLines: 3,
                                  maxLength: 70,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Masukkan nama tujuan lengkap...',
                                    hintStyle: TextStyle(fontSize: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.all(14),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
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
          bottomSheet: Consumer<OrderController>(
            builder: (context, orderController, _) {
              return Container(
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
                          onPressed: orderController.isLoading
                              ? null
                              : (_hasScanResult ? _retakeBast : _scanBast),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasScanResult
                                ? Colors.orange
                                : const Color(0xFF4A90E2),
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
                                _hasScanResult
                                    ? Icons.refresh
                                    : Icons.qr_code_scanner,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _hasScanResult ? 'Scan Ulang BAST' : 'Scan BAST',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
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
                          onPressed: (_hasScanResult &&
                                  _alamatController.text.trim().isNotEmpty &&
                                  !orderController.isLoading)
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
                                color: (_hasScanResult &&
                                        _alamatController.text
                                            .trim()
                                            .isNotEmpty &&
                                        !orderController.isLoading)
                                    ? Colors.white
                                    : Colors.grey[600],
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Kirim Data',
                                style: TextStyle(
                                  color: (_hasScanResult &&
                                          _alamatController.text
                                              .trim()
                                              .isNotEmpty &&
                                          !orderController.isLoading)
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _alamatController.dispose();
    _awbController.dispose();
    super.dispose();
  }
}

// Scan BAST Screen
class ScanBastScreen extends StatefulWidget {
  const ScanBastScreen({super.key});

  @override
  State<ScanBastScreen> createState() => _ScanBastScreenState();
}

class _ScanBastScreenState extends State<ScanBastScreen> {
  late MobileScannerController _scannerController;
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

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
            controller: _scannerController,
            onDetect: (capture) {
              if (!_isScanned && capture.barcodes.isNotEmpty) {
                final String? code = capture.barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  print('[DEBUG] Barcode scanned: $code');
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
