class Chef {
  final String id;
  final String name;

  Chef({required this.id, required this.name});

  factory Chef.fromMap(Map<String, dynamic> map) {
    return Chef(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
}
