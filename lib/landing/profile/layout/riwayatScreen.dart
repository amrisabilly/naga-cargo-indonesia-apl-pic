import 'package:flutter/material.dart';

class RiwayatBottomSheet extends StatelessWidget {
  final bool isLoadingHistory;
  final List<dynamic> scanHistory;

  const RiwayatBottomSheet({
    super.key,
    required this.isLoadingHistory,
    required this.scanHistory,
  });

  // Helper function untuk format tanggal
  String _formatTanggal(String? dateString) {
    if (dateString == null || dateString == '-') return '-';

    try {
      // Parse tanggal dari string
      DateTime date = DateTime.parse(dateString);

      // Format ke DD/MM/YYYY
      String day = date.day.toString().padLeft(2, '0');
      String month = date.month.toString().padLeft(2, '0');
      String year = date.year.toString();

      return '$day/$month/$year';
    } catch (e) {
      // Jika gagal parse, kembalikan string asli
      return dateString;
    }
  }

  Widget _buildBottomSheetHandle() {
    return Container(
      width: 60,
      height: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildBottomSheetTitle(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 650;

    return Text(
      'Riwayat Scan BAST',
      style: TextStyle(
        fontSize: isSmallScreen ? 14 : 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildRiwayatContent(
    ScrollController scrollController,
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 650;

    if (isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (scanHistory.isEmpty) {
      return Center(
        child: Text(
          'Belum ada riwayat scan.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: scanHistory.length,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: isSmallScreen ? 6 : 10,
      ),
      itemBuilder: (context, index) {
        final item = scanHistory[index];
        return _buildRiwayatCard(item, context);
      },
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> item, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 650;

    final kodeBast = item['AWB'] ?? '-';
    final namaTujuan = item['tujuan'] ?? '-';
    final tanggal = _formatTanggal(item['created_at']);
    final status = item['status'] ?? 'Terkirim';

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
        border: Border.all(color: Colors.blue[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: isSmallScreen ? 3 : 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRiwayatCardHeader(kodeBast, status, context),
          SizedBox(height: isSmallScreen ? 4 : 6),
          _buildRiwayatCardTujuan(namaTujuan, context),
          SizedBox(height: isSmallScreen ? 4 : 6),
          _buildRiwayatCardTanggal(tanggal, context),
        ],
      ),
    );
  }

  Widget _buildRiwayatCardHeader(
    String kodeBast,
    String status,
    BuildContext context,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 650;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            kodeBast,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A90E2),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 4 : 6,
            vertical: isSmallScreen ? 2 : 3,
          ),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(isSmallScreen ? 4 : 6),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: isSmallScreen ? 8 : 10,
              color: Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiwayatCardTujuan(String namaTujuan, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 650;

    return Text(
      namaTujuan,
      style: TextStyle(
        fontSize: isSmallScreen ? 10 : 12,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      maxLines: isSmallScreen ? 1 : 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRiwayatCardTanggal(String tanggal, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 650;

    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: isSmallScreen ? 10 : 12,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            tanggal,
            style: TextStyle(
              fontSize: isSmallScreen ? 9 : 11,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 650;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: isSmallScreen ? 0.6 : 0.7,
        minChildSize: isSmallScreen ? 0.3 : 0.4,
        maxChildSize: isSmallScreen ? 0.85 : 0.95,
        builder:
            (context, scrollController) => Column(
              children: [
                _buildBottomSheetHandle(),
                _buildBottomSheetTitle(context),
                SizedBox(height: isSmallScreen ? 6 : 10),
                Expanded(
                  child: _buildRiwayatContent(scrollController, context),
                ),
              ],
            ),
      ),
    );
  }
}
