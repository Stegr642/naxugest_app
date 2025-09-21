import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class FournisseursProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _fournisseurs = [];
  bool _isLoading = false;
  String _error = '';

  List<Map<String, dynamic>> get fournisseurs => _fournisseurs;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchFournisseurs() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      final data = await supabase
          .from('fournisseurs')
          .select()
          .order('nom', ascending: true);
      _fournisseurs = List<Map<String, dynamic>>.from(data as List<dynamic>);
    } catch (e) {
      _error = 'Erreur lors de la récupération des fournisseurs : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFournisseur(Map<String, dynamic> fournisseur) async {
    final inserted =
        await supabase.from('fournisseurs').insert(fournisseur).select();
    _fournisseurs.add(inserted.first);
    notifyListeners();
  }

  Future<void> updateFournisseur(
      String id, Map<String, dynamic> fournisseur) async {
    await supabase.from('fournisseurs').update(fournisseur).eq('id', id);
    final index = _fournisseurs.indexWhere((f) => f['id'] == id);
    if (index != -1) {
      _fournisseurs[index] = {..._fournisseurs[index], ...fournisseur};
    }
    notifyListeners();
  }

  Future<void> deleteFournisseur(String id) async {
    await supabase.from('fournisseurs').delete().eq('id', id);
    _fournisseurs.removeWhere((f) => f['id'] == id);
    notifyListeners();
  }
}
