import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class FacturesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _factures = [];
  bool _isLoading = false;
  String _error = '';

  List<Map<String, dynamic>> get factures => _factures;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchFactures() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      final data = await supabase
          .from('factures')
          .select()
          .order('date_facture', ascending: false);
      _factures = List<Map<String, dynamic>>.from(data as List<dynamic>);
    } catch (e) {
      _error = 'Erreur lors de la récupération des factures : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFacture(Map<String, dynamic> facture) async {
    final inserted = await supabase.from('factures').insert(facture).select();
    _factures.add(inserted.first);
    notifyListeners();
  }

  Future<void> updateFacture(String id, Map<String, dynamic> facture) async {
    await supabase.from('factures').update(facture).eq('id', id);
    final index = _factures.indexWhere((f) => f['id'] == id);
    if (index != -1) _factures[index] = {..._factures[index], ...facture};
    notifyListeners();
  }

  Future<void> deleteFacture(String id) async {
    await supabase.from('factures').delete().eq('id', id);
    _factures.removeWhere((f) => f['id'] == id);
    notifyListeners();
  }
}
