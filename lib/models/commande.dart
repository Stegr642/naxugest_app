import 'commande_detail.dart';

class Commande {
  final String id;
  final String chantierId;
  final String chefId;
  final String? statut;
  final List<CommandeDetail>? details;
  final String? chantierNom; // pour affichage

  Commande({
    required this.id,
    required this.chantierId,
    required this.chefId,
    this.statut,
    this.details,
    this.chantierNom,
  });

  factory Commande.fromMap(Map<String, dynamic> map) {
    return Commande(
      id: map['id'] as String,
      chantierId: map['chantier_id'] as String,
      chefId: map['chef_equipe_id'] as String,
      statut: map['statut'] as String?,
      chantierNom: map['chantier_nom'] as String?,
      details: map['details'] != null
          ? (map['details'] as List<dynamic>)
              .map((d) => CommandeDetail.fromMap(d as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chantier_id': chantierId,
      'chef_equipe_id': chefId,
      'statut': statut,
      'chantier_nom': chantierNom,
      'details': details?.map((d) => d.toMap()).toList(),
    };
  }
}
