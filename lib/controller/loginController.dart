import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/location_service.dart';

class LoginController extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic>? _userData;
  String? _namaDaerah;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  String? get namaDaerah => _namaDaerah;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();

  static const String _userDataKey = 'user_data';
  static const String _namaDaerahKey = 'nama_daerah';
  static const String _isLoggedInKey = 'is_logged_in';

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Simpan user data ke SharedPreferences setelah login sukses
  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_userData != null) {
        // Simpan user data sebagai JSON string
        await prefs.setString(_userDataKey, jsonEncode(_userData));
        print('[DEBUG] User data disimpan ke SharedPreferences');
      }
      
      if (_namaDaerah != null) {
        await prefs.setString(_namaDaerahKey, _namaDaerah!);
        print('[DEBUG] Nama daerah disimpan ke SharedPreferences');
      }
      
      await prefs.setBool(_isLoggedInKey, true);
      print('[DEBUG] Login status: true');
    } catch (e) {
      print('[DEBUG] ERROR menyimpan user data: $e');
    }
  }

  /// Ambil user data dari SharedPreferences saat app startup
  Future<void> loadSavedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final userDataJson = prefs.getString(_userDataKey);
      final namaDaerah = prefs.getString(_namaDaerahKey);
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (userDataJson != null && isLoggedIn) {
        _userData = jsonDecode(userDataJson);
        _namaDaerah = namaDaerah;
        print('[DEBUG] User data dimuat dari SharedPreferences: ${_userData?['nama']}');
        notifyListeners();
      }
    } catch (e) {
      print('[DEBUG] ERROR memuat user data: $e');
    }
  }

  /// Fungsi login utama (dengan SharedPreferences)
  Future<void> login(BuildContext context) async {
    _errorMessage = '';

    // Validasi input
    if (usernameController.text.trim().isEmpty) {
      _errorMessage = 'Username tidak boleh kosong';
      notifyListeners();
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      _errorMessage = 'Password tidak boleh kosong';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Validasi kredensial melalui API
      final loginResult = await _authService.loginPIC(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      print('[DEBUG] LoginResult: $loginResult');

      if (!loginResult['success']) {
        _errorMessage = loginResult['message'];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Simpan data user SEBELUM cek lokasi
      _userData = loginResult['user'];
      _namaDaerah = loginResult['nama_daerah'];
      
      print('[DEBUG] User data tersimpan: $_userData');
      print('[DEBUG] Nama daerah: $_namaDaerah');
      
      // NOTIFY LISTENERS SETELAH DATA TERSIMPAN
      notifyListeners();

      // 2. Dapatkan lokasi saat ini
      final locationResult = await _locationService.getCurrentLocation();
      
      if (!locationResult['success']) {
        _errorMessage = locationResult['message'];
        _isLoading = false;
        _userData = null;
        _namaDaerah = null;
        notifyListeners();
        return;
      }

      Position position = locationResult['position'];

      // 3. Dapatkan nama daerah dari lokasi
      final areaResult = await _locationService.getAreaFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!areaResult['success']) {
        _errorMessage = areaResult['message'];
        _isLoading = false;
        _userData = null;
        _namaDaerah = null;
        notifyListeners();
        return;
      }

      String lokasiDaerah = areaResult['area_name'];

      print('[DEBUG] Lokasi daerah dari GPS: $lokasiDaerah');
      print('[DEBUG] Daerah user dari API: $_namaDaerah');

      // 4. Bandingkan lokasi dengan daerah user dari API
      if (_namaDaerah != null && 
          lokasiDaerah.toLowerCase() == _namaDaerah!.toLowerCase()) {
        // SIMPAN DATA KE SHAREDPREFERENCES
        await _saveUserData();
        
        // Login berhasil
        _isLoading = false;
        notifyListeners();
        
        print('[DEBUG] Login SUKSES! User: ${_userData?['nama']}, Daerah: $_namaDaerah');
        
        // Navigasi SETELAH notifyListeners
        if (context.mounted) {
          context.go('/beranda_pic');
        }
      } else {
        // Lokasi tidak sesuai
        _errorMessage = 
            'Akses ditolak! Lokasi Anda di $lokasiDaerah tidak sesuai dengan daerah kerja $_namaDaerah.';
        _isLoading = false;
        _userData = null;
        _namaDaerah = null;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      _userData = null;
      _namaDaerah = null;
      notifyListeners();
      print('[DEBUG] ERROR Login: $e');
    }
  }

  /// Logout dan hapus semua data
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('[DEBUG] SharedPreferences cleared');
      
      _userData = null;
      _namaDaerah = null;
      usernameController.clear();
      passwordController.clear();
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      print('[DEBUG] ERROR logout: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
