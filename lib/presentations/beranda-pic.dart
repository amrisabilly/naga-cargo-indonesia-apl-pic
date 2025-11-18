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
  final TextEditingController _awbController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();
  final TextEditingController _penerimaController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  bool _hasScanResult = false;
  String _scannedCode = '';

  @override
  void initState() {
    super.initState();
    print('[DEBUG] BerandaPicScreen initState dipanggil');
    
    // Listen ke perubahan AWB controller
    _awbController.addListener(_onAwbChanged);
  }

  /// Handle perubahan AWB (baik dari scan maupun manual input)
  void _onAwbChanged() {
    print('[DEBUG] AWB changed: ${_awbController.text}');
    setState(() {
      _scannedCode = _awbController.text.trim();
      _hasScanResult = _scannedCode.isNotEmpty;
    });
  }

  Future<void> _scanBast() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanBastScreen()),
    );

    if (result != null && result is String) {
      print('[DEBUG] Scan result: $result');
      _awbController.text = result;
      // _onAwbChanged akan dipanggil otomatis dari listener
    }
  }

  void _retakeBast() {
    print('[DEBUG] Retake/Clear BAST');
    _awbController.clear();
    // _onAwbChanged akan dipanggil otomatis dari listener
  }

  Future<void> _submitData() async {
    print('[DEBUG] === SUBMIT DATA DIMULAI ===');
    print('[DEBUG] AWB: $_scannedCode');
    print('[DEBUG] Tujuan: ${_tujuanController.text.trim()}');
    print('[DEBUG] Penerima: ${_penerimaController.text.trim()}');
    print('[DEBUG] No HP: ${_noHpController.text.trim()}');
    print('[DEBUG] ID PIC: ${Provider.of<LoginController>(context, listen: false).userData?['id_user']}');
    print('[DEBUG] isLoading: ${Provider.of<OrderController>(context, listen: false).isLoading}');

    // Validasi input
    if (_tujuanController.text.trim().isEmpty) {
      print('[DEBUG] ERROR: Tujuan kosong');
      _showErrorDialog('Nama tujuan tidak boleh kosong');
      return;
    }

    if (_penerimaController.text.trim().isEmpty) {
      print('[DEBUG] ERROR: Penerima kosong');
      _showErrorDialog('Nama penerima tidak boleh kosong');
      return;
    }

    if (_noHpController.text.trim().isEmpty) {
      print('[DEBUG] ERROR: No HP kosong');
      _showErrorDialog('Nomor HP tidak boleh kosong');
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
    
    final success = await orderController.submitOrder(
      awb: _scannedCode,
      idPic: idPic,
      tujuan: _tujuanController.text.trim(),
      penerima: _penerimaController.text.trim(),
      noHp: _noHpController.text.trim(),
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
            _tujuanController.clear();
            _penerimaController.clear();
            _noHpController.clear();
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          onChanged: (value) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF4A90E2)),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4A90E2),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<LoginController>(
      builder: (context, loginController, _) {
        print('[DEBUG] Build BerandaPicScreen - userData: ${loginController.userData}');

        final userData = loginController.userData;

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
                                    // UBAH: TextField sekarang bisa di-edit
                                    TextField(
                                      controller: _awbController,
                                      readOnly: false,
                                      decoration: InputDecoration(
                                        hintText: 'Scan atau ketik kode BAST di sini',
                                        prefixIcon: const Icon(
                                          Icons.qr_code,
                                          color: Color(0xFF4A90E2),
                                        ),
                                        suffixIcon: _hasScanResult
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.clear,
                                                  color: Colors.red,
                                                ),
                                                onPressed: _retakeBast,
                                              )
                                            : null,
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF4A90E2),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF4A90E2),
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                    if (_hasScanResult) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF357ABD),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Kode BAST terisi: $_scannedCode',
                                              style: const TextStyle(
                                                color: Color(0xFF357ABD),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Tujuan Input
                              _buildInputField(
                                controller: _tujuanController,
                                label: 'Nama Tujuan',
                                hintText: 'Masukkan nama tujuan lengkap...',
                                icon: Icons.location_on,
                                maxLines: 2,
                                maxLength: 70,
                              ),

                              // Penerima Input
                              _buildInputField(
                                controller: _penerimaController,
                                label: 'Nama Penerima',
                                hintText: 'Masukkan nama penerima lengkap...',
                                icon: Icons.person_outline,
                                maxLength: 100,
                              ),

                              // No HP Input
                              _buildInputField(
                                controller: _noHpController,
                                label: 'Nomor HP',
                                hintText: 'Masukkan nomor HP penerima...',
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                maxLength: 13,
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
                      // Scan Button
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
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 2,
                          ),
                          onPressed: orderController.isLoading ? null : _scanBast,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_hasScanResult &&
                                  _tujuanController.text.trim().isNotEmpty &&
                                  _penerimaController.text.trim().isNotEmpty &&
                                  _noHpController.text.trim().isNotEmpty &&
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
                                        _tujuanController.text
                                            .trim()
                                            .isNotEmpty &&
                                        _penerimaController.text
                                            .trim()
                                            .isNotEmpty &&
                                        _noHpController.text
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
                                          _tujuanController.text
                                              .trim()
                                              .isNotEmpty &&
                                          _penerimaController.text
                                              .trim()
                                              .isNotEmpty &&
                                          _noHpController.text
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
    _awbController.removeListener(_onAwbChanged);
    _awbController.dispose();
    _tujuanController.dispose();
    _penerimaController.dispose();
    _noHpController.dispose();
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
