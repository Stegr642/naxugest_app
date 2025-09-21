import 'package:supabase_flutter/supabase_flutter.dart';

class ChantiersService {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAll() async {
    try {
      final result = await client.from('chantiers').select() as List<dynamic>;
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des chantiers: $e');
    }
  }

  Future<void> add(Map<String, dynamic> chantier) async {
    try {
      await client.from('chantiers').insert(chantier);
    } catch (e) {
      throw Exception('Erreur lors de l’ajout du chantier: $e');
    }
  }

  Future<void> remove(int id) async {
    try {
      await client.from('chantiers').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du chantier: $e');
    }
  }
}
