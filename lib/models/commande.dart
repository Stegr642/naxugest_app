class Commande {
  final int id;
  final int chantierId;
  final String chantierName;
  final List<int> productIds;

  Commande({
    required this.id,
    required this.chantierId,
    required this.chantierName,
    required this.productIds,
  });

  factory Commande.fromMap(Map<String, dynamic> map) {
    return Commande(
      id: map['id'] as int,
      chantierId: map['chantierId'] as int,
      chantierName: map['chantierName'] as String,
      productIds: List<int>.from(map['productIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chantierId': chantierId,
      'chantierName': chantierName,
      'productIds': productIds,
    };
  }
}
