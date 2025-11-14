import 'package:cargo_app/auth/login.dart';
import 'package:cargo_app/landing/landing.dart';
import 'package:cargo_app/presentations/beranda-pic.dart';
import 'package:cargo_app/presentations/profile-pic.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/Login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/beranda_pic',
      builder: (context, state) => const BerandaPicScreen(),
    ),
    GoRoute(
      path: '/profile_pic', // Tambahkan route baru
      builder: (context, state) => const ProfilePicScreen(),
    ),
  ],
);
