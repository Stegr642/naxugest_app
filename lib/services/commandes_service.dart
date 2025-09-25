import 'package:naxugest_app/providers/supabase_client_provider.dart';
import '../models/commande.dart';
import '../models/commande_detail.dart';

class CommandesService {
  static Future<List<Commande>> getAll() async {
    final response = await supabase
        .from('commandes')
        .select('*, details:commandes_details(*)');
    final data = response as List<dynamic>;
    return data
        .map((row) => Commande.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addCommande(Commande commande) async {
    await supabase.from('commandes').insert({
      'id': commande.id,
      'chantier_id': commande.chantierId,
      'chef_equipe_id': commande.chefId,
      'statut': commande.statut,
    });
    if (commande.details != null) {
      for (var d in commande.details!) {
        await supabase.from('commandes_details').insert({
          'id': d.id,
          'commande_id': commande.id,
          'produit_id': d.produitId,
          'quantite': d.quantite,
        });
      }
    }
  }
}
