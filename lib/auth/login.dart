import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../controller/loginController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _showLottie = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Perbaiki logika responsif dengan range yang lebih baik
    final isSmallScreen = screenHeight < 650;
    final isMediumScreen = screenHeight >= 650 && screenHeight <= 800;
    final isLargeScreen = screenHeight > 800;

    // Responsive sizing yang lebih baik
    final titleFontSize =
        isSmallScreen
            ? 28.0
            : isMediumScreen
            ? 32.0
            : 36.0;
    final headerHeight =
        isSmallScreen
            ? 50.0
            : isMediumScreen
            ? 60.0
            : 80.0;
    final lottieSize =
        isSmallScreen
            ? 120.0
            : isMediumScreen
            ? 140.0
            : 160.0;
    final horizontalPadding = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: const Color(0xFF4A90E2),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: screenHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: headerHeight),
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              final isFull =
                  notification.extent >= notification.maxExtent - 0.01;
              if (_showLottie != isFull) {
                setState(() {
                  _showLottie = isFull;
                });
              }
              return false;
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.73,
              minChildSize: 0.73,
              maxChildSize: 1.0,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical:
                            isSmallScreen
                                ? 16.0
                                : isMediumScreen
                                ? 20.0
                                : 24.0,
                      ),
                      child: Consumer<LoginController>(
                        builder: (context, loginController, child) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height:
                                    isSmallScreen
                                        ? 16
                                        : isMediumScreen
                                        ? 20
                                        : 24,
                              ),

                              if (_showLottie)
                                Center(
                                  child: Lottie.asset(
                                    'assets/images/transport.json',
                                    width: lottieSize,
                                    height: lottieSize,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              if (_showLottie)
                                SizedBox(
                                  height:
                                      isSmallScreen
                                          ? 6
                                          : isMediumScreen
                                          ? 8
                                          : 10,
                                ),

                              Center(
                                child: Text(
                                  'Selamat Datang!',
                                  style: TextStyle(
                                    fontSize:
                                        isSmallScreen
                                            ? 20
                                            : isMediumScreen
                                            ? 24
                                            : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height:
                                    isSmallScreen
                                        ? 6
                                        : isMediumScreen
                                        ? 8
                                        : 10,
                              ),

                              Center(
                                child: Text(
                                  'Silakan masuk ke akun Anda',
                                  style: TextStyle(
                                    fontSize:
                                        isSmallScreen
                                            ? 13
                                            : isMediumScreen
                                            ? 15
                                            : 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height:
                                    isSmallScreen
                                        ? 20
                                        : isMediumScreen
                                        ? 26
                                        : 30,
                              ),

                              if (loginController.errorMessage.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.all(
                                    isSmallScreen
                                        ? 10
                                        : isMediumScreen
                                        ? 12
                                        : 14,
                                  ),
                                  margin: EdgeInsets.only(
                                    bottom:
                                        isSmallScreen
                                            ? 12
                                            : isMediumScreen
                                            ? 16
                                            : 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red[600],
                                        size:
                                            isSmallScreen
                                                ? 18
                                                : isMediumScreen
                                                ? 20
                                                : 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          loginController.errorMessage,
                                          style: TextStyle(
                                            color: Colors.red[600],
                                            fontSize:
                                                isSmallScreen
                                                    ? 12
                                                    : isMediumScreen
                                                    ? 13
                                                    : 14,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: loginController.clearError,
                                        iconSize:
                                            isSmallScreen
                                                ? 18
                                                : isMediumScreen
                                                ? 20
                                                : 22,
                                      ),
                                    ],
                                  ),
                                ),

                              SizedBox(
                                height:
                                    isSmallScreen
                                        ? 20
                                        : isMediumScreen
                                        ? 26
                                        : 30,
                              ),

                              Text(
                                'Username',
                                style: TextStyle(
                                  fontSize:
                                      isSmallScreen
                                          ? 13
                                          : isMediumScreen
                                          ? 15
                                          : 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(
                                height:
                                    isSmallScreen
                                        ? 6
                                        : isMediumScreen
                                        ? 8
                                        : 10,
                              ),

                              TextFormField(
                                textInputAction: TextInputAction.next,
                                controller: loginController.usernameController,
                                style: TextStyle(
                                  fontSize:
                                      isSmallScreen
                                          ? 13
                                          : isMediumScreen
                                          ? 15
                                          : 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan username Anda',
                                  hintStyle: TextStyle(
                                    fontSize:
                                        isSmallScreen
                                            ? 12
                                            : isMediumScreen
                                            ? 14
                                            : 15,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF4A90E2),
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outlined,
                                    size:
                                        isSmallScreen
                                            ? 18
                                            : isMediumScreen
                                            ? 20
                                            : 22,
                                    color: Colors.grey[600],
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal:
                                        isSmallScreen
                                            ? 12
                                            : isMediumScreen
                                            ? 14
                                            : 16,
                                    vertical:
                                        isSmallScreen
                                            ? 12
                                            : isMediumScreen
                                            ? 14
                                            : 16,
                                  ),
                                ),
                              ),

                              SizedBox(
                                height:
                                    isSmallScreen
                                        ? 16
                                        : isMediumScreen
                                        ? 20
                                        : 24,
                              ),

                              Text(
                                'Password',
                                style: TextStyle(
                                  fontSize:
                                      isSmallScreen
                                          ? 13
                                          : isMediumScreen
                                          ? 15
                                          : 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(
                                height:
                                    isSmallScreen
                                        ? 6
                                        : isMediumScreen
                                        ? 8
                                        : 10,
                              ),

                              TextFormField(
                                controller: loginController.passwordController,
                                textInputAction: TextInputAction.done,
                                obscureText: _obscurePassword,
                                style: TextStyle(
                                  fontSize:
                                      isSmallScreen
                                          ? 13
                                          : isMediumScreen
                                          ? 15
                                          : 16,
                                ),
                                onFieldSubmitted: (_) {
                                  if (!loginController.isLoading) {
                                    loginController.login(context);
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Masukkan password Anda',
                                  hintStyle: TextStyle(
                                    fontSize:
                                        isSmallScreen
                                            ? 12
                                            : isMediumScreen
                                            ? 14
                                            : 15,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF4A90E2),
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outlined,
                                    size:
                                        isSmallScreen
                                            ? 18
                                            : isMediumScreen
                                            ? 20
                                            : 22,
                                    color: Colors.grey[600],
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size:
                                          isSmallScreen
                                              ? 18
                                              : isMediumScreen
                                              ? 20
                                              : 22,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: _togglePasswordVisibility,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal:
                                        isSmallScreen
                                            ? 12
                                            : isMediumScreen
                                            ? 14
                                            : 16,
                                    vertical:
                                        isSmallScreen
                                            ? 12
                                            : isMediumScreen
                                            ? 14
                                            : 16,
                                  ),
                                ),
                              ),

                              SizedBox(
                                height:
                                    isSmallScreen
                                        ? 30
                                        : isMediumScreen
                                        ? 38
                                        : 44,
                              ),

                              SizedBox(
                                width: double.infinity,
                                height:
                                    isSmallScreen
                                        ? 48
                                        : isMediumScreen
                                        ? 52
                                        : 56,
                                child: ElevatedButton(
                                  onPressed:
                                      loginController.isLoading
                                          ? null
                                          : () =>
                                              loginController.login(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A90E2),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child:
                                      loginController.isLoading
                                          ? SizedBox(
                                            height:
                                                isSmallScreen
                                                    ? 18
                                                    : isMediumScreen
                                                    ? 20
                                                    : 22,
                                            width:
                                                isSmallScreen
                                                    ? 18
                                                    : isMediumScreen
                                                    ? 20
                                                    : 22,
                                            child:
                                                const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                          )
                                          : Text(
                                            'Masuk',
                                            style: TextStyle(
                                              fontSize:
                                                  isSmallScreen
                                                      ? 15
                                                      : isMediumScreen
                                                      ? 17
                                                      : 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),

                              SizedBox(
                                height:
                                    isSmallScreen
                                        ? 24
                                        : isMediumScreen
                                        ? 30
                                        : 36,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
