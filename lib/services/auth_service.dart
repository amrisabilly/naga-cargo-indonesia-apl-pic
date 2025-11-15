import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://monitoringweb.decoratics.id/api';

  /// Login PIC dengan username dan password
  Future<Map<String, dynamic>> loginPIC({
    required String username,
    required String password,
  }) async {
    try {
      final url = '$baseUrl/PIC/login';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': responseData['user'],
          'nama_daerah': responseData['nama_daerah'],
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Username atau password salah',
        };
      } else {
        return {
          'success': false,
          'message': 'Terjadi kesalahan pada server',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error koneksi ke server: $e',
      };
    }
  }
}