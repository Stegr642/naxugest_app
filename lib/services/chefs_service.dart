import 'package:naxugest_app/providers/supabase_client_provider.dart';
import '../models/chef.dart';

class ChefsService {
  static Future<List<Chef>> getAll() async {
    final response = await supabase.from('chefs_equipe').select();
    final data = response as List<dynamic>;
    return data.map((c) => Chef.fromMap(c as Map<String, dynamic>)).toList();
  }
}
