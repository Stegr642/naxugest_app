import 'package:supabase_flutter/supabase_flutter.dart';

class ChefsService {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAll() async {
    try {
      final result = await client.from('chefs').select() as List<dynamic>;
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des chefs: $e');
    }
  }

  Future<void> add(Map<String, dynamic> chef) async {
    try {
      await client.from('chefs').insert(chef);
    } catch (e) {
      throw Exception('Erreur lors de l’ajout du chef: $e');
    }
  }

  Future<void> remove(int id) async {
    try {
      await client.from('chefs').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du chef: $e');
    }
  }
}
