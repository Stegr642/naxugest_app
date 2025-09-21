import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static late final SupabaseClient client;

  static Future<void> init() async {
    const supabaseUrl =
        String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const supabaseKey =
        String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      throw Exception(
          'Supabase URL or ANON KEY is missing. Check your dart-defines.json');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      debug: true,
    );

    client = Supabase.instance.client; // ✅ maintenant client est initialisé
  }
}
