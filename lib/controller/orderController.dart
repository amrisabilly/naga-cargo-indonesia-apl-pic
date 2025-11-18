import 'package:flutter/material.dart';
import '../services/order_service.dart';

class OrderController extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  Map<String, dynamic>? _lastOrder;
  List<dynamic> _orders = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  Map<String, dynamic>? get lastOrder => _lastOrder;
  List<dynamic> get orders => _orders;

  final OrderService _orderService = OrderService();

  /// Submit order baru dengan data lengkap
  Future<bool> submitOrder({
    required String awb,
    required int idPic,
    required String tujuan,
    required String penerima,
    required String noHp,
  }) async {
    _errorMessage = '';
    _successMessage = '';

    // Debug: print data sebelum dikirim ke API
    print('[DEBUG] === SUBMIT ORDER DATA ===');
    print('[DEBUG] AWB: $awb');
    print('[DEBUG] ID PIC: $idPic');
    print('[DEBUG] Tujuan: $tujuan');
    print('[DEBUG] Penerima: $penerima');
    print('[DEBUG] No HP: $noHp');

    // Validasi input
    if (awb.trim().isEmpty) {
      _errorMessage = 'Kode AWB/BAST tidak boleh kosong';
      notifyListeners();
      return false;
    }

    if (tujuan.trim().isEmpty) {
      _errorMessage = 'Nama tujuan tidak boleh kosong';
      notifyListeners();
      return false;
    }

    if (tujuan.trim().length > 70) {
      _errorMessage = 'Nama tujuan maksimal 70 karakter';
      notifyListeners();
      return false;
    }

    if (penerima.trim().isEmpty) {
      _errorMessage = 'Nama penerima tidak boleh kosong';
      notifyListeners();
      return false;
    }

    if (penerima.trim().length > 100) {
      _errorMessage = 'Nama penerima maksimal 100 karakter';
      notifyListeners();
      return false;
    }

    if (noHp.trim().isEmpty) {
      _errorMessage = 'Nomor HP tidak boleh kosong';
      notifyListeners();
      return false;
    }

    // Validasi nomor HP (hanya angka, 10-13 digit)
    if (!RegExp(r'^[0-9]{10,13}$').hasMatch(noHp.trim())) {
      _errorMessage = 'Nomor HP harus angka 10-13 digit';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _orderService.storeOrder(
        awb: awb.trim(),
        idPic: idPic,
        tujuan: tujuan.trim(),
        penerima: penerima.trim(),
        noHp: noHp.trim(),
      );

      _isLoading = false;

      if (result['success']) {
        _successMessage = result['message'];
        _lastOrder = result['order'];
        print('[DEBUG] ✓ Order berhasil: $_successMessage');
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        print('[DEBUG] ✗ Order gagal: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      print('[DEBUG] ✗ Exception: $e');
      notifyListeners();
      return false;
    }
  }

  /// Mendapatkan riwayat order
  Future<void> fetchRiwayatOrder({required int idPic}) async {
    print('[DEBUG] === FETCH RIWAYAT ORDER ===');
    _errorMessage = '';
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _orderService.getRiwayatOrder(idPic: idPic);

      _isLoading = false;

      if (result['success']) {
        _orders = result['orders'] ?? [];
        
        // SORT data berdasarkan created_at (terbaru duluan)
        _orders.sort((a, b) {
          try {
            final dateA = DateTime.parse(a['created_at'].toString());
            final dateB = DateTime.parse(b['created_at'].toString());
            return dateB.compareTo(dateA);
          } catch (e) {
            print('[DEBUG] Error sorting: $e');
            return 0;
          }
        });

        print('[DEBUG] ✓ Riwayat dimuat: ${_orders.length} item');
        notifyListeners();
      } else {
        _errorMessage = result['message'];
        print('[DEBUG] ✗ Error: $_errorMessage');
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      print('[DEBUG] ✗ Exception: $e');
      notifyListeners();
    }
  }

  /// Clear messages
  void clearMessages() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }

  /// Reset controller
  void reset() {
    _errorMessage = '';
    _successMessage = '';
    _lastOrder = null;
    _orders = [];
    notifyListeners();
  }
}