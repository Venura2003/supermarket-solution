class ProductModel {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final String? barcode;

  ProductModel({required this.id, required this.name, required this.price, required this.quantity, this.barcode});

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'],
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
        barcode: json['barcode'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'barcode': barcode,
      };
}
