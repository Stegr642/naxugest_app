import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/produits_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Supabase avec dart-defines.json
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    debug: true,
  );

  runApp(const NaxuGestApp());
}

class NaxuGestApp extends StatelessWidget {
  const NaxuGestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NaxuGest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ProduitsScreen(),
    );
  }
}
