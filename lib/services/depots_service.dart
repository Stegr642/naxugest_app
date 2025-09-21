import 'package:supabase_flutter/supabase_flutter.dart';

class DepotsService {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAll() async {
    try {
      final result = await client.from('depots').select() as List<dynamic>;
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des dépôts: $e');
    }
  }

  Future<void> add(Map<String, dynamic> depot) async {
    try {
      await client.from('depots').insert(depot);
    } catch (e) {
      throw Exception('Erreur lors de l’ajout du dépôt: $e');
    }
  }

  Future<void> remove(int id) async {
    try {
      await client.from('depots').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du dépôt: $e');
    }
  }
}
