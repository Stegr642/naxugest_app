import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static late SupabaseClient client;

  /// Initialise Supabase avec les valeurs venant de `dart-defines.json`
  static Future<void> init() async {
    // Récupère les variables injectées par --dart-define
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
          "❌ Supabase URL ou Anon Key manquant dans dart-defines.json");
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    client = Supabase.instance.client;
  }
}
