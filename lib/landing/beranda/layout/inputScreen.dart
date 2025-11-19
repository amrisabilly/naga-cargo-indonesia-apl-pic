import 'package:flutter/material.dart';

class InputFormSection extends StatelessWidget {
  final TextEditingController tujuanController;
  final TextEditingController penerimaController;
  final TextEditingController noHpController;
  final Function(String) onFieldChanged;

  const InputFormSection({
    super.key,
    required this.tujuanController,
    required this.penerimaController,
    required this.noHpController,
    required this.onFieldChanged,
  });

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 650;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          onChanged: onFieldChanged,
          style: TextStyle(fontSize: isSmallScreen ? 12 : 13),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              color: Colors.grey[500],
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF4A90E2),
              size: isSmallScreen ? 18 : 20,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 14,
              vertical: isSmallScreen ? 12 : 14,
            ),
            counterStyle: TextStyle(
              fontSize: isSmallScreen ? 10 : 11,
              color: Colors.grey[600],
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInputField(
          context: context,
          controller: tujuanController,
          label: 'Nama Tujuan',
          hintText: 'Contoh: Toko Sinar Mas, Jl. Sudirman No. 15',
          icon: Icons.location_on,
          maxLines: 2, // Diperbesar untuk alamat yang panjang
          maxLength: 100, // Diperbesar untuk alamat lengkap
          keyboardType: TextInputType.streetAddress,
          textCapitalization: TextCapitalization.words,
        ),
        _buildInputField(
          context: context,
          controller: penerimaController,
          label: 'Nama Penerima',
          hintText: 'Nama penerima lengkap...',
          icon: Icons.person_outline,
          maxLength: 100,
          textCapitalization: TextCapitalization.words,
        ),
        _buildInputField(
          context: context,
          controller: noHpController,
          label: 'Nomor HP',
          hintText: 'Contoh: 08123456789',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          maxLength: 15, // Diperbesar untuk nomor HP yang panjang
        ),
      ],
    );
  }
}
