import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/supabase/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase(); // initialise Supabase
  runApp(const App());
}
