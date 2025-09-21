import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chantiers_service.dart';

final chantiersProvider =
    StateNotifierProvider<ChantiersNotifier, List<Map<String, dynamic>>>(
  (ref) => ChantiersNotifier(),
);

class ChantiersNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final ChantiersService _service = ChantiersService();

  ChantiersNotifier() : super([]);

  Future<void> fetchAll() async {
    try {
      state = await _service.fetchAll();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> add(Map<String, dynamic> chantier) async {
    try {
      await _service.add(chantier);
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
