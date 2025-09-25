class Chantier {
  final String id;
  final String name;

  Chantier({required this.id, required this.name});

  factory Chantier.fromMap(Map<String, dynamic> map) {
    return Chantier(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
}
