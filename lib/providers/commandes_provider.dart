import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CommandesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _commandes = [];
  bool _loading = false;
  String _error = '';

  List<Map<String, dynamic>> get commandes => _commandes;
  bool get loading => _loading;
  String get error => _error;

  // Charger les commandes depuis Supabase
  Future<void> fetchCommandes() async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      final data = await supabase
          .from('commandes')
          .select(
              'id, nom_commande, chantier, chef_equipe, status, date_commande')
          .order('date_commande', ascending: false);

      _commandes = List<Map<String, dynamic>>.from(data as List<dynamic>);
    } catch (e) {
      _error = 'Erreur lors de la récupération des commandes : $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Ajouter une commande
  Future<void> addCommande(Map<String, dynamic> payload) async {
    try {
      final inserted =
          await supabase.from('commandes').insert(payload).select();
      _commandes.add(inserted.first);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l’ajout de la commande : $e';
      notifyListeners();
    }
  }

  // Modifier une commande
  Future<void> updateCommande(String id, Map<String, dynamic> payload) async {
    try {
      await supabase.from('commandes').update(payload).eq('id', id);
      final index = _commandes.indexWhere((c) => c['id'] == id);
      if (index != -1) _commandes[index] = {..._commandes[index], ...payload};
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la mise à jour : $e';
      notifyListeners();
    }
  }

  // Supprimer une commande
  Future<void> deleteCommande(String id) async {
    try {
      await supabase.from('commandes').delete().eq('id', id);
      _commandes.removeWhere((c) => c['id'] == id);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la suppression : $e';
      notifyListeners();
    }
  }

  // Recherche filtrée
  List<Map<String, dynamic>> filteredCommandes(String query) {
    if (query.isEmpty) return _commandes;
    final lowerQuery = query.toLowerCase();
    return _commandes.where((c) {
      final nom = c['nom_commande']?.toString().toLowerCase() ?? '';
      final chantier = c['chantier']?.toString().toLowerCase() ?? '';
      return nom.contains(lowerQuery) || chantier.contains(lowerQuery);
    }).toList();
  }
}
