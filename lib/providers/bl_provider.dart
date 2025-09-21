import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/bl.dart';
import '../../providers/supabase_provider.dart';

final blProvider = StateNotifierProvider<BLNotifier, List<BL>>(
  (ref) => BLNotifier(ref),
);

class BLNotifier extends StateNotifier<List<BL>> {
  final Ref ref;
  BLNotifier(this.ref) : super([]) {
    fetchBLs();
  }

  Future<void> fetchBLs() async {
    try {
      final client = ref.read(supabaseClient);
      final response = await client.from('bls').select();
      if (response.error != null) return;

      final data = response.data as List<dynamic>;
      state = data.map((e) => BL.fromMap(e)).toList();
    } catch (e) {
      print('Exception fetchBLs: $e');
    }
  }

  Future<void> add(BL b) async {
    try {
      final client = ref.read(supabaseClient);
      final response = await client.from('bls').insert([b.toMap()]);
      if (response.error != null) return;

      state = [...state, b];
    } catch (e) {
      print('Exception add BL: $e');
    }
  }

  Future<void> remove(int id) async {
    try {
      final client = ref.read(supabaseClient);
      final response = await client.from('bls').delete().eq('id', id);
      if (response.error != null) return;

      state = state.where((b) => b.id != id).toList();
    } catch (e) {
      print('Exception remove BL: $e');
    }
  }

  Future<void> update(BL b) async {
    try {
      final client = ref.read(supabaseClient);
      final response =
          await client.from('bls').update(b.toMap()).eq('id', b.id);
      if (response.error != null) return;

      state = state.map((x) => x.id == b.id ? b : x).toList();
    } catch (e) {
      print('Exception update BL: $e');
    }
  }
}
