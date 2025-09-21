import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'screens/dashboard_screen.dart';
import 'screens/products_screen.dart';
import 'screens/chantiers_screen.dart';
import 'screens/fournisseurs_screen.dart';
import 'screens/chefs_screen.dart';
import 'screens/commandes_screen.dart';
import 'screens/bl_screen.dart';
import 'screens/factures_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NaxuGest',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.dashboard,
      routes: {
        AppRoutes.dashboard: (context) => const DashboardScreen(),
        AppRoutes.products: (context) => const ProductsScreen(),
        AppRoutes.chantiers: (context) => const ChantiersScreen(),
        AppRoutes.fournisseurs: (context) => const FournisseursScreen(),
        AppRoutes.chefs: (context) => const ChefsScreen(),
        AppRoutes.commandes: (context) => const CommandesScreen(),
        AppRoutes.bl: (context) => const BlScreen(),
        AppRoutes.factures: (context) => const FacturesScreen(),
      },
    );
  }
}
