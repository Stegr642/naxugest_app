import 'package:flutter/material.dart';
import '../screens/Login_Screen.dart';
import '../screens/home_screen.dart';
import '../screens/produits_screen.dart';
import '../screens/commandes_screen.dart';
import '../screens/reset_password_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (_) => const LoginScreen(),
    '/home': (_) => const HomeScreen(),
    '/produits': (_) => const ProduitsScreen(),
    '/commandes': (_) => const CommandesScreen(),
    '/reset_password': (_) => const ResetPasswordScreen(),
  };
}
