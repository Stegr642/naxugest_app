import 'package:supabase_flutter/supabase_flutter.dart';

class ProduitsService {
  final SupabaseClient _client = Supabase.instance.client;

  // Liste des produits
  Future<List<Map<String, dynamic>>> getProduits() async {
    try {
      final produits = await _client.from('produits').select().order('id');
      return produits;
    } catch (e) {
      throw Exception("Erreur lors de la récupération des produits: $e");
    }
  }

  // Ajouter un produit
  Future<void> addProduit(Map<String, dynamic> produit) async {
    try {
      await _client.from('produits').insert(produit);
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du produit: $e");
    }
  }

  // Supprimer un produit
  Future<void> deleteProduit(int id) async {
    try {
      await _client.from('produits').delete().eq('id', id);
    } catch (e) {
      throw Exception("Erreur lors de la suppression du produit: $e");
    }
  }
}
