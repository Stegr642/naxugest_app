import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static late final SupabaseClient client;

  static Future<void> init(
      {required String url, required String anonKey}) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    client = Supabase.instance.client;
  }
}
