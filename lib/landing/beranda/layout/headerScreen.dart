import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeaderProfile extends StatelessWidget {
  final String namaPic;
  final double screenHeight;

  const HeaderProfile({
    super.key,
    required this.namaPic,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 650;

    return Container(
      height: isSmallScreen ? screenHeight * 0.13 : screenHeight * 0.17,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: isSmallScreen ? 12.0 : 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.go('/profile_pic'),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: isSmallScreen ? 18 : 22,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: const Color(0xFF4A90E2),
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Selamat Datang',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isSmallScreen ? 13 : 13,
                            ),
                          ),
                          Text(
                            namaPic,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 13 : 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
