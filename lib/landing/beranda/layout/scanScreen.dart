import 'package:flutter/material.dart';

class ScanBastSection extends StatelessWidget {
  final TextEditingController awbController;
  final bool hasScanResult;
  final String scannedCode;
  final VoidCallback onScanPressed;
  final VoidCallback onClearPressed;

  const ScanBastSection({
    super.key,
    required this.awbController,
    required this.hasScanResult,
    required this.scannedCode,
    required this.onScanPressed,
    required this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 650;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.qr_code_scanner,
                size: isSmallScreen ? 16 : 18,
                color: Colors.white,
              ),
              label: Text(
                'Scan BAST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 10 : 12,
                ),
              ),
              onPressed: onScanPressed,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),
          Text(
            'Atau masukkan kode BAST secara manual:',
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isSmallScreen ? 5 : 6),
          TextField(
            controller: awbController,
            readOnly: false,
            style: TextStyle(fontSize: isSmallScreen ? 12 : 13),
            decoration: InputDecoration(
              hintText: 'Masukkan kode',
              hintStyle: TextStyle(fontSize: isSmallScreen ? 11 : 12),
              prefixIcon: Icon(
                Icons.qr_code,
                color: const Color(0xFF4A90E2),
                size: isSmallScreen ? 18 : 20,
              ),
              suffixIcon:
                  hasScanResult
                      ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.blue,
                          size: isSmallScreen ? 18 : 20,
                        ),
                        onPressed: onClearPressed,
                      )
                      : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                borderSide: const BorderSide(color: Color(0xFF4A90E2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                borderSide: const BorderSide(
                  color: Color(0xFF4A90E2),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 10 : 12,
                vertical: isSmallScreen ? 8 : 10,
              ),
            ),
          ),
          if (hasScanResult) ...[
            SizedBox(height: isSmallScreen ? 10 : 12),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFF357ABD),
                  size: isSmallScreen ? 16 : 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'BAST: $scannedCode',
                    style: TextStyle(
                      color: const Color(0xFF357ABD),
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 11 : 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
