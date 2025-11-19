import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cargo_app/controller/loginController.dart';
import 'package:cargo_app/controller/orderController.dart';
import 'package:cargo_app/landing/beranda/layout/headerScreen.dart';
import 'package:cargo_app/landing/beranda/layout/bottomScreen.dart';
import 'package:cargo_app/landing/beranda/layout/inputScreen.dart';
import 'package:cargo_app/landing/beranda/layout/scanScreen.dart';

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
    _awbController.addListener(_onAwbChanged);
  }

  void _onAwbChanged() {
    setState(() {
      _scannedCode = _awbController.text.trim();
      _hasScanResult = _scannedCode.isNotEmpty;
    });
  }

  bool get _hasValidInput {
    return _hasScanResult &&
        _tujuanController.text.trim().isNotEmpty &&
        _penerimaController.text.trim().isNotEmpty &&
        _noHpController.text.trim().isNotEmpty;
  }

  Future<void> _scanBast() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanBastScreen()),
    );

    if (result != null && result is String) {
      _awbController.text = result;
    }
  }

  void _retakeBast() {
    _awbController.clear();
  }

  Future<void> _submitData() async {
    if (!_hasValidInput) return;

    print('[DEBUG] === SUBMIT DATA ===');
    final orderController = Provider.of<OrderController>(
      context,
      listen: false,
    );
    final loginController = Provider.of<LoginController>(
      context,
      listen: false,
    );

    final userData = loginController.userData;
    if (userData == null) return;

    try {
      final result = await orderController.submitOrder(
        awb: _awbController.text.trim(),
        tujuan: _tujuanController.text.trim(),
        penerima: _penerimaController.text.trim(),
        noHp: _noHpController.text.trim(),
        idPic: userData['id_user'] as int,
      );

      if (result) {
        _showSuccessDialog('Data berhasil dikirim!');
        // Clear form
        _awbController.clear();
        _tujuanController.clear();
        _penerimaController.clear();
        _noHpController.clear();
      } else {
        // Cek apakah error karena AWB duplicate
        String errorMessage = orderController.errorMessage;
        if (errorMessage.contains('already been taken') ||
            errorMessage.contains('sudah pernah digunakan') ||
            errorMessage.contains('duplicate')) {
          _showAwbDuplicateDialog();
        } else {
          _showErrorDialog(
            errorMessage.isNotEmpty
                ? errorMessage
                : 'Gagal mengirim data. Silakan coba lagi.',
          );
        }
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('already been taken') ||
          errorMsg.contains('sudah pernah digunakan')) {
        _showAwbDuplicateDialog();
      } else {
        _showErrorDialog('Error: $errorMsg');
      }
    }
  }

  void _showAwbDuplicateDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'AWB Sudah Terdaftar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Clear AWB untuk scan ulang
                        _awbController.clear();
                        setState(() {
                          _hasScanResult = false;
                          _scannedCode = '';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Scan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                const SizedBox(width: 8),
                const Text('Berhasil'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: const Color(0xFF4A90E2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600], size: 24),
                const SizedBox(width: 8),
                const Text('Error'),
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
        final userData = loginController.userData;

        if (userData == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && context.mounted) {
              context.go('/login');
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final namaPic = userData['nama'] ?? 'PIC Naga Cargo';

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFFF5F7FA),
          body: Column(
            children: [
              HeaderProfile(namaPic: namaPic, screenHeight: screenHeight),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, -20, 0),
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenHeight = MediaQuery.of(context).size.height;
                        final screenWidth = MediaQuery.of(context).size.width;

                        // Perbaiki logika responsif
                        final isSmallScreen = screenHeight < 650;
                        final isMediumScreen =
                            screenHeight >= 650 && screenHeight <= 800;
                        final isLargeScreen = screenHeight > 800;

                        final bottomInset =
                            MediaQuery.of(context).viewInsets.bottom;

                        return SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            screenWidth * 0.05,
                            isSmallScreen
                                ? 12
                                : isMediumScreen
                                ? 16
                                : 20,
                            screenWidth * 0.05,
                            (isSmallScreen
                                    ? 100
                                    : isMediumScreen
                                    ? 120
                                    : 140) +
                                bottomInset,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ScanBastSection(
                                awbController: _awbController,
                                hasScanResult: _hasScanResult,
                                scannedCode: _scannedCode,
                                onScanPressed: _scanBast,
                                onClearPressed: _retakeBast,
                              ),
                              SizedBox(
                                height:
                                    isSmallScreen
                                        ? 16
                                        : isMediumScreen
                                        ? 20
                                        : 24,
                              ),
                              InputFormSection(
                                tujuanController: _tujuanController,
                                penerimaController: _penerimaController,
                                noHpController: _noHpController,
                                onFieldChanged: (value) => setState(() {}),
                              ),
                              SizedBox(
                                height:
                                    isSmallScreen
                                        ? 16
                                        : isMediumScreen
                                        ? 20
                                        : 24,
                              ),
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
          bottomSheet: BottomActionButtons(
            hasScanResult: _hasScanResult,
            hasValidInput: _hasValidInput,
            onScanPressed: _scanBast,
            onSubmitPressed: _submitData,
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

// Keep ScanBastScreen in the same file or move to separate file
class ScanBastScreen extends StatefulWidget {
  const ScanBastScreen({super.key});

  @override
  State<ScanBastScreen> createState() => _ScanBastScreenState();
}

class _ScanBastScreenState extends State<ScanBastScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan BAST'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          if (!_isScanning) return;

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              setState(() {
                _isScanning = false;
              });
              Navigator.pop(context, barcode.rawValue);
              break;
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
