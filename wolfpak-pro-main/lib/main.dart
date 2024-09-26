import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wolfpak/constants/colors.dart';
import 'package:wolfpak/providers/products_list_provider.dart';
import 'package:wolfpak/screens/bottom_navigation_menu_screen.dart';
import 'package:wolfpak/screens/forgot_password_screen.dart';
import 'package:wolfpak/screens/profile_screen.dart';
import 'package:wolfpak/screens/sign_in_screen.dart';
import 'package:wolfpak/screens/sign_up_screen.dart';
import 'package:wolfpak/screens/splash_screen.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ProductListProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wolfpak',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF262626),
      ),
      home: const SplashScreen(),
      navigatorKey: GlobalKey<NavigatorState>(),
      initialRoute: "/",
      routes: {
        '/sign-in': (context) => const SignInScreen(),
        '/sign-up': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/main': (context) => const BottomNavigationMenuScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
