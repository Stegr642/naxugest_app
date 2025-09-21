import 'package:flutter/material.dart';
import 'package:naxugest_app/services/supabase_client_service.dart';
import 'package:naxugest_app/screens/produits_screen.dart'; // ✅ très important

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseClientService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NaxuGest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ProduitsScreen(), // ✅ ici
    );
  }
}
