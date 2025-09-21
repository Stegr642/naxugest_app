import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/depots_service.dart';

final depotsProvider =
    StateNotifierProvider<DepotsNotifier, List<Map<String, dynamic>>>(
  (ref) => DepotsNotifier(),
);

class DepotsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final DepotsService _service = DepotsService();

  DepotsNotifier() : super([]);

  Future<void> fetchAll() async {
    try {
      state = await _service.fetchAll();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> add(Map<String, dynamic> depot) async {
    try {
      await _service.add(depot);
      await fetchAll();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> remove(int id) async {
    try {
      await _service.remove(id);
      state = state.where((d) => d['id'] != id).toList();
    } catch (e) {
      throw Exception(e);
    }
  }
}
