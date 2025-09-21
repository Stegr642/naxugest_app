class Mouvement {
  final String id;
  final String productId;
  final String chantierId;
  final int quantity;
  final DateTime date;

  Mouvement(
      {required this.id,
      required this.productId,
      required this.chantierId,
      required this.quantity,
      required this.date});
}
