class Facture {
  final int id;
  final double montant;

  Facture({required this.id, required this.montant});

  factory Facture.fromMap(Map<String, dynamic> map) {
    return Facture(
      id: map['id'] as int,
      montant: (map['montant'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'montant': montant};
  }
}
