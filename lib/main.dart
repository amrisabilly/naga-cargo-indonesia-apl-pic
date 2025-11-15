import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cargo_app/routes/router.dart';
import 'package:provider/provider.dart';
import 'controller/loginController.dart';
import 'controller/orderController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('[DEBUG] === APP STARTUP ===');
  
  // Load saved user data dari SharedPreferences
  final loginController = LoginController();
  print('[DEBUG] LoginController created: ${loginController.hashCode}');
  
  await loginController.loadSavedUserData();
  
  print('[DEBUG] App started. User data loaded: ${loginController.userData != null}');
  
  runApp(MainApp(loginController: loginController));
}

class MainApp extends StatelessWidget {
  final LoginController loginController;
  
  const MainApp({super.key, required this.loginController});

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] MainApp build - LoginController: ${loginController.hashCode}');
    
    return MultiProvider(
      providers: [
        // PENTING: Gunakan .value untuk instance yang sudah ada
        ChangeNotifierProvider<LoginController>.value(
          value: loginController,
        ),
        ChangeNotifierProvider(
          create: (_) => OrderController(),
          lazy: false,
        ),
      ],
      // PENTING: Gunakan child, bukan builder
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        theme: ThemeData(textTheme: GoogleFonts.soraTextTheme()),
        routeInformationProvider: router.routeInformationProvider,
      ),
    );
  }
}
