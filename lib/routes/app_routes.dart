import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/produits_screen.dart';
import '../screens/reset_password_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
    '/produits': (context) => const ProduitsScreen(),
    '/reset-password': (context) => const ResetPasswordScreen(),
  };
}
