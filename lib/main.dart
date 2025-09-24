import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/commandes_screen.dart';
import 'screens/nouvelle_commande_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lire les valeurs depuis dart-define
  final supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
  final supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
        'Supabase URL ou ANON KEY manquant. Vérifie ton dart-defines.json');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const NaxuGestApp());
}

class NaxuGestApp extends StatelessWidget {
  const NaxuGestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NaxuGest',
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/commandes',
      routes: {
        '/commandes': (_) => const CommandesScreen(),
        '/nouvelle_commande': (_) => const NouvelleCommandeScreen(),
      },
    );
  }
}
