import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class LoginController extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  // Daftar wilayah kerja yang diizinkan
  final List<String> _wilayahDiizinkan = ["Bantul", "Sleman"];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<String> get wilayahDiizinkan => _wilayahDiizinkan;

  // Controllers untuk form
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Fungsi untuk mendapatkan lokasi saat ini
  Future<Position?> _getCurrentLocation() async {
    try {
      // Cek apakah layanan lokasi aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Layanan lokasi tidak aktif. Silakan aktifkan GPS.';
        notifyListeners();
        return null;
      }

      // Cek permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Izin lokasi ditolak.';
          notifyListeners();
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage =
            'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan.';
        notifyListeners();
        return null;
      }

      // Dapatkan posisi saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      _errorMessage = 'Gagal mendapatkan lokasi: $e';
      notifyListeners();
      return null;
    }
  }

  // Fungsi untuk memanggil API Nominatim
  Future<Map<String, dynamic>?> _panggilAPINominatim(
    double lat,
    double lon,
  ) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'NagaCargoApp/1.0', // Nominatim memerlukan User-Agent
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _errorMessage = 'Gagal mendapatkan informasi lokasi dari server.';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error koneksi: $e';
      notifyListeners();
      return null;
    }
  }

  // Fungsi utama untuk cek akses kurir
  Future<bool> cekAksesKurir(double lat, double lon) async {
    try {
      // 1. Panggil API Nominatim
      Map<String, dynamic>? responsAPI = await _panggilAPINominatim(lat, lon);

      if (responsAPI == null) {
        return false; // Gagal mendapatkan data lokasi
      }

      // 2. Ekstraksi nama kabupaten (county)
      String? namaKabupatenKurir;

      if (responsAPI['address'] != null &&
          responsAPI['address']['county'] != null) {
        namaKabupatenKurir = responsAPI['address']['county'].toString();
      } else {
        _errorMessage = 'Tidak dapat menentukan wilayah kerja Anda.';
        notifyListeners();
        return false;
      }

      // 3. Lakukan pengecekan
      bool aksesDisetujui = _wilayahDiizinkan.contains(namaKabupatenKurir);

      if (!aksesDisetujui) {
        _errorMessage =
            'Akses ditolak. Anda berada di wilayah $namaKabupatenKurir. '
            'Akses hanya diizinkan untuk wilayah: ${_wilayahDiizinkan.join(", ")}';
        notifyListeners();
      }

      return aksesDisetujui;
    } catch (e) {
      _errorMessage = 'Error saat mengecek akses: $e';
      notifyListeners();
      return false;
    }
  }

  // Fungsi login utama
  Future<void> login(BuildContext context) async {
    // Reset error message
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
      // 1. Validasi kredensial (simulasi - ganti dengan API real)
      bool kredensialValid = await _validasiKredensial(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      if (!kredensialValid) {
        _errorMessage = 'Username atau password salah';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Dapatkan lokasi saat ini
      Position? position = await _getCurrentLocation();
      if (position == null) {
        _isLoading = false;
        return; // Error message sudah di-set di _getCurrentLocation
      }

      // 3. Cek akses kurir berdasarkan lokasi
      bool aksesDisetujui = await cekAksesKurir(
        position.latitude,
        position.longitude,
      );

      _isLoading = false;
      notifyListeners();

      if (aksesDisetujui) {
        // Login berhasil, navigasi ke beranda
        if (context.mounted) {
          context.go('/beranda_pic');
        }
      }
      // Jika akses ditolak, error message sudah di-set di cekAksesKurir
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
    }
  }

  // Simulasi validasi kredensial (ganti dengan API real)
  Future<bool> _validasiKredensial(String username, String password) async {
    // Simulasi delay network
    await Future.delayed(const Duration(seconds: 1));

    // Untuk demo, anggap username = "kurir" dan password = "123"
    // Ganti dengan panggilan API real
    return username == "pic" && password == "123";
  }

  // Fungsi untuk clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Fungsi untuk menambah wilayah diizinkan (untuk admin)
  void tambahWilayahDiizinkan(String wilayah) {
    if (!_wilayahDiizinkan.contains(wilayah)) {
      _wilayahDiizinkan.add(wilayah);
      notifyListeners();
    }
  }

  // Fungsi untuk menghapus wilayah diizinkan (untuk admin)
  void hapusWilayahDiizinkan(String wilayah) {
    _wilayahDiizinkan.remove(wilayah);
    notifyListeners();
  }
}
