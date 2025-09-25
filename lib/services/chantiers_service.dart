import 'package:naxugest_app/providers/supabase_client_provider.dart';
import '../models/chantier.dart';

class ChantiersService {
  static Future<List<Chantier>> getAll() async {
    final response = await supabase.from('chantiers').select();
    final data = response as List<dynamic>;
    return data
        .map((c) => Chantier.fromMap(c as Map<String, dynamic>))
        .toList();
  }
}
