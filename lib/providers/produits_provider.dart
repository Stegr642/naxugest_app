import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/produits_service.dart';

final produitsProvider = StateNotifierProvider<ProduitsNotifier,
    AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => ProduitsNotifier(ProduitsService()),
);

class ProduitsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ProduitsService _service;

  ProduitsNotifier(this._service) : super(const AsyncLoading()) {
    loadProduits();
  }

  Future<void> loadProduits() async {
    try {
      final produits = await _service.getProduits();
      state = AsyncData(produits);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addProduit(Map<String, dynamic> produit) async {
    try {
      await _service.addProduit(produit);
      loadProduits(); // recharge la liste
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteProduit(int id) async {
    try {
      await _service.deleteProduit(id);
      loadProduits();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
