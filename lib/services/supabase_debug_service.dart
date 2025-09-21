import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDebugService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Vérifie que la connexion est OK
  Future<void> testConnexion() async {
    try {
      final response = await _client.from('produits').select().limit(1);

      print("✅ Connexion Supabase OK !");
      print("Exemple produit : $response");
    } catch (e) {
      print("❌ Erreur de connexion Supabase: $e");
    }
  }

  /// Liste toutes les tables publiques disponibles
  Future<void> listTables() async {
    try {
      final response = await _client
          .rpc('pg_tables') // ⚠️ nécessite une fonction RPC si pas activée
          .select();

      print("📋 Tables disponibles : $response");
    } catch (e) {
      print("⚠️ Impossible de lister les tables avec RPC: $e");
      print(
          "👉 Conseil : tu peux exécuter directement une requête SQL côté Supabase pour voir les tables.");
    }
  }

  /// Récupère les 10 premiers enregistrements d’une table donnée
  Future<void> dumpTable(String tableName) async {
    try {
      final response = await _client.from(tableName).select().limit(10);
      print("📦 Contenu de $tableName (10 premiers rows) : $response");
    } catch (e) {
      print("❌ Erreur lors du dump de $tableName: $e");
    }
  }
}
