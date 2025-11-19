import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cargo_app/controller/orderController.dart';

class BottomActionButtons extends StatelessWidget {
  final bool hasScanResult;
  final bool hasValidInput;
  final VoidCallback onScanPressed;
  final VoidCallback onSubmitPressed;

  const BottomActionButtons({
    super.key,
    required this.hasScanResult,
    required this.hasValidInput,
    required this.onScanPressed,
    required this.onSubmitPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 650;

    return Consumer<OrderController>(
      builder: (context, orderController, _) {
        return Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FA), // Ubah dari Colors.white ke F5F7FA
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: isSmallScreen ? 44 : 48,
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
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 10 : 12,
                        ),
                      ),
                      elevation: 2,
                    ),
                    onPressed: orderController.isLoading ? null : onScanPressed,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 10),
                SizedBox(
                  width: double.infinity,
                  height: isSmallScreen ? 44 : 48,
                  child: ElevatedButton(
                    onPressed:
                        (hasValidInput && !orderController.isLoading)
                            ? onSubmitPressed
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 10 : 12,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.send,
                          color:
                              (hasValidInput && !orderController.isLoading)
                                  ? Colors.white
                                  : Colors.grey[600],
                          size: isSmallScreen ? 16 : 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kirim Data',
                          style: TextStyle(
                            color:
                                (hasValidInput && !orderController.isLoading)
                                    ? Colors.white
                                    : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
