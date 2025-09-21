class Depot {
  final int id;
  final String name;

  Depot({required this.id, required this.name});

  factory Depot.fromMap(Map<String, dynamic> map) {
    return Depot(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}
