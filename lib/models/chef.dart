class Chef {
  final int id;
  final String name;

  Chef({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Chef.fromMap(Map<String, dynamic> map) {
    return Chef(
      id: map['id'],
      name: map['name'],
    );
  }
}
