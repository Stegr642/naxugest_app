import 'package:supabase_flutter/supabase_flutter.dart';

class FacturesService {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAll() async {
    try {
      final result = await client.from('factures').select() as List<dynamic>;
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des factures: $e');
    }
  }

  Future<void> add(Map<String, dynamic> facture) async {
    try {
      await client.from('factures').insert(facture);
    } catch (e) {
      throw Exception('Erreur lors de l’ajout de la facture: $e');
    }
  }

  Future<void> remove(int id) async {
    try {
      await client.from('factures').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la facture: $e');
    }
  }
}
