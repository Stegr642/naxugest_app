class Chantier {
  final int id;
  final String name;

  Chantier({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Chantier.fromMap(Map<String, dynamic> map) {
    return Chantier(
      id: map['id'],
      name: map['name'],
    );
  }
}
