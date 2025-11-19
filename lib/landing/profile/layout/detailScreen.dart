import 'package:flutter/material.dart';

class UserDetailsCard extends StatelessWidget {
  final String username;
  final String noHp;
  final String daerah;

  const UserDetailsCard({
    super.key,
    required this.username,
    required this.noHp,
    required this.daerah,
  });

  // Helper function untuk title case
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 650;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4A90E2),
            size: isSmallScreen ? 16 : 20,
          ),
        ),
        SizedBox(width: isSmallScreen ? 10 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 650;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: isSmallScreen ? 12 : 20,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: isSmallScreen ? 8 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Akun',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            _buildDetailRow(
              context: context,
              icon: Icons.person,
              label: 'Username',
              value: _toTitleCase(
                username,
              ), // Gunakan title case untuk username
            ),
            Divider(height: isSmallScreen ? 20 : 24),
            _buildDetailRow(
              context: context,
              icon: Icons.phone,
              label: 'No HP',
              value: noHp,
            ),
            Divider(height: isSmallScreen ? 20 : 24),
            _buildDetailRow(
              context: context,
              icon: Icons.location_on,
              label: 'Wilayah',
              value: daerah,
            ),
          ],
        ),
      ),
    );
  }
}
