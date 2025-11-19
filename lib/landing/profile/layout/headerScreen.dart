import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String namaPic;
  final String idPic;

  const ProfileHeader({super.key, required this.namaPic, required this.idPic});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 650;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 20 : 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            namaPic,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 24,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
