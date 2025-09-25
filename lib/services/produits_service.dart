import 'package:naxugest_app/models/product.dart';
import 'package:naxugest_app/supabase_client.dart';

class ProduitsService {
  final supabase = SupabaseClientService.client;

  Future<List<Product>> getAllProduits() async {
    final response = await supabase
        .from('produits')
        .select()
        .order('nom', ascending: true)
        .execute();

    if (response.error != null) {
      throw Exception(
          'Erreur lors de la récupération des produits: ${response.error!.message}');
    }

    final data = response.data as List<dynamic>;
    return data.map((p) {
      return Product(
        id: p['id'],
        nom: p['nom'],
        description: p['description'] ?? '',
      );
    }).toList();
  }
}
