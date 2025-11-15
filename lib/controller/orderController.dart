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

  /// Submit order baru
  Future<bool> submitOrder({
    required String awb,
    required int idPic,
    required String tujuan,
  }) async {
    _errorMessage = '';
    _successMessage = '';

    // Debug: print data sebelum dikirim ke API
    print('[DEBUG] Submit Order Data:');
    print('AWB: $awb');
    print('ID PIC: $idPic');
    print('Tujuan: $tujuan');

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

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _orderService.storeOrder(
        awb: awb.trim(),
        idPic: idPic,
        tujuan: tujuan.trim(),
      );

      _isLoading = false;

      if (result['success']) {
        _successMessage = result['message'];
        _lastOrder = result['order'];
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Mendapatkan riwayat order
  Future<void> fetchRiwayatOrder({required int idPic}) async {
    _errorMessage = '';
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _orderService.getRiwayatOrder(idPic: idPic);

      _isLoading = false;

      if (result['success']) {
        _orders = result['orders'];
        notifyListeners();
      } else {
        _errorMessage = result['message'];
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
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