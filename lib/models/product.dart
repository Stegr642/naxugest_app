class Product {
  final int id;
  final String nom;
  final String description;

  Product({
    required this.id,
    required this.nom,
    required this.description,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      nom: map['nom'],
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
    };
  }
}
