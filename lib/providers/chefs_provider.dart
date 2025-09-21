import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chefs_service.dart';

final chefsProvider =
    StateNotifierProvider<ChefsNotifier, List<Map<String, dynamic>>>(
  (ref) => ChefsNotifier(),
);

class ChefsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final ChefsService _service = ChefsService();

  ChefsNotifier() : super([]);

  Future<void> fetchAll() async {
    try {
      state = await _service.fetchAll();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> add(Map<String, dynamic> chef) async {
    try {
      await _service.add(chef);
      await fetchAll();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> remove(int id) async {
    try {
      await _service.remove(id);
      state = state.where((c) => c['id'] != id).toList();
    } catch (e) {
      throw Exception(e);
    }
  }
}
