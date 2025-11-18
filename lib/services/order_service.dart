import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static const String baseUrl = 'https://monitoringweb.decoratics.id/api';

  /// Simpan order baru dari PIC dengan data lengkap
  Future<Map<String, dynamic>> storeOrder({
    required String awb,
    required int idPic,
    required String tujuan,
    required String penerima,
    required String noHp,
  }) async {
    try {
      print('[DEBUG] === STORE ORDER SERVICE ===');
      print('[DEBUG] URL: $baseUrl/PIC/order');
      print('[DEBUG] Data: AWB=$awb, id_pic=$idPic, tujuan=$tujuan, penerima=$penerima, no_hp=$noHp');
      
      final url = '$baseUrl/PIC/order';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'AWB': awb,
          'id_pic': idPic,
          'tujuan': tujuan,
          'Penerima': penerima,
          'no_hp': noHp,
        }),
      );

      print('[DEBUG] Status code: ${response.statusCode}');
      print('[DEBUG] Response: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[DEBUG] ✓ Order berhasil dibuat');
        return {
          'success': true,
          'message': responseData['message'] ?? 'Order berhasil dibuat',
          'order': responseData['order'],
        };
      } else if (response.statusCode == 422) {
        // Validation error
        print('[DEBUG] ✗ Validation error: ${responseData['message']}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Data tidak valid',
          'errors': responseData['errors'],
        };
      } else {
        print('[DEBUG] ✗ Server error: ${responseData['message']}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Terjadi kesalahan pada server',
        };
      }
    } catch (e) {
      print('[DEBUG] ✗ Exception: $e');
      return {
        'success': false,
        'message': 'Error koneksi ke server: $e',
      };
    }
  }

  /// Mendapatkan riwayat order berdasarkan ID PIC
  Future<Map<String, dynamic>> getRiwayatOrder({
    required int idPic,
  }) async {
    try {
      print('[DEBUG] === GET RIWAYAT ORDER ===');
      
      final url = Uri.parse('$baseUrl/PIC/riwayat-order')
          .replace(queryParameters: {'id_pic': idPic.toString()});
      
      print('[DEBUG] URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('[DEBUG] Status code: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final orders = responseData['orders'] ?? responseData['data'] ?? [];
        
        print('[DEBUG] ✓ Riwayat order berhasil dimuat: ${orders.length} item');

        return {
          'success': true,
          'orders': orders is List ? orders : [],
          'message': responseData['message'] ?? 'Berhasil mendapatkan riwayat order',
        };
      } else {
        print('[DEBUG] ✗ Error: ${responseData['message']}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal mendapatkan riwayat order',
          'orders': [],
        };
      }
    } catch (e) {
      print('[DEBUG] ✗ Exception: $e');
      return {
        'success': false,
        'message': 'Error koneksi ke server: $e',
        'orders': [],
      };
    }
  }
}