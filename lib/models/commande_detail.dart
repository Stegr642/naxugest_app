class CommandeDetail {
  final String id;
  final String commandeId;
  final String produitId;
  int quantite;
  String? produitNom; // Pour affichage du nom du produit

  CommandeDetail({
    required this.id,
    required this.commandeId,
    required this.produitId,
    required this.quantite,
    this.produitNom,
  });

  factory CommandeDetail.fromMap(Map<String, dynamic> map) {
    return CommandeDetail(
      id: map['id'] as String,
      commandeId: map['commande_id'] as String,
      produitId: map['produit_id'] as String,
      quantite: map['quantite'] as int,
      produitNom: map['produit_nom'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commande_id': commandeId,
      'produit_id': produitId,
      'quantite': quantite,
      'produit_nom': produitNom,
    };
  }
}
