import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onRiwayatPressed;
  final VoidCallback onLogoutPressed;

  const ActionButtons({
    super.key,
    required this.onRiwayatPressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 650;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        children: [
          // Button Riwayat Scan BAST
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 40 : 44, // Diperbesar dari 36-40 ke 40-44
            child: ElevatedButton.icon(
              onPressed: onRiwayatPressed,
              icon: Icon(
                Icons.history,
                color: Colors.white,
                size: isSmallScreen ? 15 : 17, // Diperbesar dari 14-16 ke 15-17
              ),
              label: Text(
                'Riwayat Scan BAST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize:
                      isSmallScreen ? 13 : 14, // Diperbesar dari 12-13 ke 13-14
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    isSmallScreen ? 10 : 12, // Diperbesar dari 8-10 ke 10-12
                  ),
                ),
                elevation: 2,
              ),
            ),
          ),

          SizedBox(
            height: isSmallScreen ? 10 : 12, // Diperbesar dari 8-10 ke 10-12
          ),

          // Button Logout
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 40 : 44, // Diperbesar dari 36-40 ke 40-44
            child: ElevatedButton.icon(
              onPressed: onLogoutPressed,
              icon: Icon(
                Icons.logout,
                color: Colors.white,
                size: isSmallScreen ? 15 : 17, // Diperbesar dari 14-16 ke 15-17
              ),
              label: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize:
                      isSmallScreen ? 13 : 14, // Diperbesar dari 12-13 ke 13-14
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    isSmallScreen ? 10 : 12, // Diperbesar dari 8-10 ke 10-12
                  ),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
