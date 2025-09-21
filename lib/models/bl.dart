class BL {
  final int id;
  final int chantierId;
  final String chantierName;

  BL({required this.id, required this.chantierId, required this.chantierName});

  factory BL.fromMap(Map<String, dynamic> map) {
    return BL(
      id: map['id'] as int,
      chantierId: map['chantierId'] as int,
      chantierName: map['chantierName'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'chantierId': chantierId, 'chantierName': chantierName};
  }
}
