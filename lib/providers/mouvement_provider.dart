import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/mouvement.dart';
import '../../providers/supabase_provider.dart';

final mouvementProvider =
    StateNotifierProvider<MouvementNotifier, List<Mouvement>>(
  (ref) => MouvementNotifier(ref),
);

class MouvementNotifier extends StateNotifier<List<Mouvement>> {
  final Ref ref;
  MouvementNotifier(this.ref) : super([]) {
    fetchMouvements();
  }

  Future<void> fetchMouvements() async {
    try {
      final client = ref.read(supabaseClient);
      final response = await client.from('mouvements').select();
      if (response.error != null) return;

      final data = response.data as List<dynamic>;
      state = data.map((e) => Mouvement.fromMap(e)).toList();
    } catch (e) {
      print('Exception fetchMouvements: $e');
    }
  }

  Future<void> add(Mouvement m) async {
    try {
      final client = ref.read(supabaseClient);
      final response = await client.from('mouvements').insert([m.toMap()]);
      if (response.error != null) return;

      state = [...state, m];
    } catch (e) {
      print('Exception add Mouvement: $e');
    }
  }

  Future<void> remove(int id) async {
    try {
      final client = ref.read(supabaseClient);
      final response = await client.from('mouvements').delete().eq('id', id);
      if (response.error != null) return;

      state = state.where((m) => m.id != id).toList();
    } catch (e) {
      print('Exception remove Mouvement: $e');
    }
  }

  Future<void> update(Mouvement m) async {
    try {
      final client = ref.read(supabaseClient);
      final response =
          await client.from('mouvements').update(m.toMap()).eq('id', m.id);
      if (response.error != null) return;

      state = state.map((x) => x.id == m.id ? m : x).toList();
    } catch (e) {
      print
