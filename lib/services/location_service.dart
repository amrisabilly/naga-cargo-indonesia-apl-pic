import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  /// Mendapatkan lokasi saat ini
  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // Cek apakah layanan lokasi aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'success': false,
          'message': 'Layanan lokasi tidak aktif. Silakan aktifkan GPS.',
        };
      }

      // Cek permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            'success': false,
            'message': 'Izin lokasi ditolak.',
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'success': false,
          'message': 'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan.',
        };
      }

      // Dapatkan posisi saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return {
        'success': true,
        'position': position,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mendapatkan lokasi: $e',
      };
    }
  }

  /// Memanggil API Nominatim untuk mendapatkan informasi lokasi
  Future<Map<String, dynamic>?> _callNominatimAPI(double lat, double lon) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'NagaCargoApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Mendapatkan nama daerah dari koordinat
  Future<Map<String, dynamic>> getAreaFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      Map<String, dynamic>? response = await _callNominatimAPI(latitude, longitude);

      if (response == null) {
        return {
          'success': false,
          'message': 'Gagal mendapatkan informasi lokasi dari server.',
        };
      }

      String? namaDaerah;
      
      if (response['address'] != null) {
        // Cek city terlebih dahulu (untuk kota besar seperti Surabaya)
        if (response['address']['city'] != null) {
          namaDaerah = response['address']['city'].toString();
        }
        // Jika tidak ada city, cek county (untuk kabupaten seperti Bantul, Sleman)
        else if (response['address']['county'] != null) {
          namaDaerah = response['address']['county'].toString();
        }
        // Jika tidak ada county, cek state_district
        else if (response['address']['state_district'] != null) {
          namaDaerah = response['address']['state_district'].toString();
        }
      }

      if (namaDaerah == null) {
        return {
          'success': false,
          'message': 'Tidak dapat menentukan wilayah kerja Anda.',
        };
      }

      return {
        'success': true,
        'area_name': namaDaerah,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error saat mengecek lokasi: $e',
      };
    }
  }
}