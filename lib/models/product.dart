class Product {
  final int id;
  final String name;
  final int quantity;
  final double price; // obligatoire

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        name: map['name'],
        quantity: map['quantity'],
        price: map['price'].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'price': price,
      };
}
