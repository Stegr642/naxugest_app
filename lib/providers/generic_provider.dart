import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naxugest_app/supabase_client.dart';

class GenericNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final String table;
  final client = SupabaseClientService.client;

  GenericNotifier(this.table) : super([]);

  /// Récupérer toutes les lignes
  Future<void> fetchAll() async {
    try {
      final data = await client.from(table).select() as List<dynamic>;
      state = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération depuis $table: $e');
    }
  }

  /// Ajouter une ligne
  Future<void> add(Map<String, dynamic> row) async {
    try {
      final response = await client.from(table).insert(row).select().single();
      state = [...state, Map<String, dynamic>.from(response)];
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout dans $table: $e');
    }
  }

  /// Supprimer une ligne par id
  Future<void> remove(int id) async {
    try {
      await client.from(table).delete().eq('id', id);
      state = state.where((row) => row['id'] != id).toList();
    } catch (e) {
      throw Exception('Erreur lors de la suppression dans $table: $e');
    }
  }

  // Produits
  final produitsProvider =
      StateNotifierProvider<GenericNotifier, List<Map<String, dynamic>>>(
          (ref) => GenericNotifier('produits'));

// Dépôts
  final depotsProvider =
      StateNotifierProvider<GenericNotifier, List<Map<String, dynamic>>>(
          (ref) => GenericNotifier('depots'));

// Chantiers
  final chantiersProvider =
      StateNotifierProvider<GenericNotifier, List<Map<String, dynamic>>>(
          (ref) => GenericNotifier('chantiers'));

// Chefs d'équipe
  final chefsProvider =
      StateNotifierProvider<GenericNotifier, List<Map<String, dynamic>>>(
          (ref) => GenericNotifier('chefs'));

// Factures
  final facturesProvider =
      StateNotifierProvider<GenericNotifier, List<Map<String, dynamic>>>(
          (ref) => GenericNotifier('factures'));

// Commandes
  final commandesProvider =
      StateNotifierProvider<GenericNotifier, List<Map<String, dynamic>>>(
          (ref) => GenericNotifier('commandes'));
}
