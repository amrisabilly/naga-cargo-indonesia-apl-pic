import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:cargo_app/controller/loginController.dart';
import 'package:cargo_app/controller/orderController.dart';
import 'package:cargo_app/landing/profile/layout/buttonScreen.dart';
import 'package:cargo_app/landing/profile/layout/headerScreen.dart';
import 'package:cargo_app/landing/profile/layout/detailScreen.dart';
import 'package:cargo_app/landing/profile/layout/riwayatScreen.dart';
import 'package:cargo_app/landing/profile/layout/logoutScreen.dart';

class ProfilePicScreen extends StatefulWidget {
  const ProfilePicScreen({super.key});

  @override
  State<ProfilePicScreen> createState() => _ProfilePicScreenState();
}

class _ProfilePicScreenState extends State<ProfilePicScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingHistory = false;
  List<dynamic> _scanHistory = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRiwayatOrder();
    });
  }

  // SEMUA LOGIKA TETAP SAMA - TIDAK BERUBAH
  Future<void> _loadRiwayatOrder() async {
    print('[DEBUG] === LOAD RIWAYAT ORDER ===');

    final loginController = Provider.of<LoginController>(
      context,
      listen: false,
    );
    final orderController = Provider.of<OrderController>(
      context,
      listen: false,
    );

    final userData = loginController.userData;
    if (userData == null) {
      print('[DEBUG] ✗ userData NULL');
      return;
    }

    final idPic = userData['id_user'] as int;
    print('[DEBUG] ID PIC: $idPic');

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      await orderController.fetchRiwayatOrder(idPic: idPic);
      setState(() {
        _scanHistory = orderController.orders;
        _isLoadingHistory = false;
      });
      print('[DEBUG] ✓ Riwayat order dimuat: ${_scanHistory.length} item');
    } catch (e) {
      print('[DEBUG] ✗ ERROR loading riwayat: $e');
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  void _logout() {
    print('[DEBUG] Logout dialog ditampilkan');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => LogoutDialog(
            onConfirm: () async {
              print('[DEBUG] Logout dikonfirmasi');
              Navigator.pop(context);

              final loginController = Provider.of<LoginController>(
                context,
                listen: false,
              );
              await loginController.logout();
              print('[DEBUG] ✓ Logout berhasil');

              if (mounted) {
                context.go('/login');
              }
            },
            onCancel: () {
              Navigator.pop(context);
              print('[DEBUG] Logout dibatalkan');
            },
          ),
    );
  }

  void _showRiwayatBottomSheet() {
    print('[DEBUG] Riwayat bottom sheet ditampilkan');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => RiwayatBottomSheet(
            isLoadingHistory: _isLoadingHistory,
            scanHistory: _scanHistory,
          ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Profile PIC', style: TextStyle(fontSize: 18)),
      backgroundColor: const Color(0xFF4A90E2),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        iconSize: 25,
        onPressed: () {
          print('[DEBUG] Kembali ke beranda');
          context.go('/beranda_pic');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 650;

    return Consumer<LoginController>(
      builder: (context, loginController, _) {
        final userData = loginController.userData;

        if (userData == null) {
          print('[DEBUG] userData NULL di ProfilePicScreen');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/login');
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final namaPic = userData['nama'] ?? 'PIC Naga Cargo';
        final idPic = userData['id_user'] ?? 'ID001';
        final username = userData['username'] ?? '-';
        final noHp = userData['no_hp'] ?? '-';
        final daerah = loginController.namaDaerah ?? '-';

        print('[DEBUG] Profile data: nama=$namaPic, id=$idPic');

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(namaPic: namaPic, idPic: idPic.toString()),
                SizedBox(height: isSmallScreen ? 16 : 24),
                UserDetailsCard(username: username, noHp: noHp, daerah: daerah),
                SizedBox(height: isSmallScreen ? 16 : 24),
                ActionButtons(
                  onRiwayatPressed: _showRiwayatBottomSheet,
                  onLogoutPressed: _logout,
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
