import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/loginController.dart';
import '../auth/login.dart';
import '../landing/beranda/berandaScreen.dart';
import '../landing/profile/profileScreen.dart';
import '../splash/splashScreen.dart';

// Create a key untuk GoRouter agar bisa di-refresh
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  redirect: (context, state) {
    print('[DEBUG] === ROUTER REDIRECT CHECK ===');
    print('[DEBUG] Path: ${state.matchedLocation}');

    try {
      final loginController = Provider.of<LoginController>(
        context,
        listen: false,
      );
      final userData = loginController.userData;
      final isLoggedIn = userData != null;

      print('[DEBUG] isLoggedIn: $isLoggedIn');
      print('[DEBUG] userData: $userData');

      // Jika user sudah login dan mencoba ke halaman login
      if (isLoggedIn && state.matchedLocation == '/login') {
        print('[DEBUG] ✓ User sudah login, redirect ke /beranda_pic');
        return '/beranda_pic';
      }

      // Jika user belum login dan mencoba ke halaman yang butuh login
      if (!isLoggedIn &&
          state.matchedLocation != '/login' &&
          state.matchedLocation != '/') {
        print('[DEBUG] ✓ User belum login, redirect ke /login');
        return '/login';
      }

      print('[DEBUG] ✓ Navigasi normal');
      return null;
    } catch (e) {
      print('[DEBUG] ✗ ERROR di router redirect: $e');
      return '/login';
    }
  },
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        print('[DEBUG] Building LoginScreen');
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/beranda_pic',
      name: 'beranda_pic',
      builder: (context, state) {
        print('[DEBUG] Building BerandaPicScreen');
        return const BerandaPicScreen();
      },
    ),
    GoRoute(
      path: '/profile_pic',
      name: 'profile_pic',
      builder: (context, state) {
        print('[DEBUG] Building ProfilePicScreen');
        return const ProfilePicScreen();
      },
    ),
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
  ],
  initialLocation: '/',
);
