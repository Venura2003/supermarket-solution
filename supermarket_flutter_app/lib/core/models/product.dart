class Product {
  final int? id;
  final String name;
  final int? categoryId;
  final String? barcode;
  final String? imageUrl;
  final double price;
  final double costPrice;
  final int stock;
  final int lowStockThreshold;
  final DateTime? createdAt;

  Product({
    this.id,
    required this.name,
    this.categoryId,
    this.barcode,
    this.imageUrl,
    required this.price,
    this.costPrice = 0.0,
    required this.stock,
    this.lowStockThreshold = 5,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      categoryId: json['categoryId'],
      barcode: json['barcode'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'],
      lowStockThreshold: json['lowStockThreshold'] ?? 5,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'categoryId': categoryId,
      'barcode': barcode,
      'imageUrl': imageUrl,
      'price': price,
      'costPrice': costPrice,
      'stock': stock,
      'lowStockThreshold': lowStockThreshold,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    int? categoryId,
    String? barcode,
    String? imageUrl,
    double? price,
    double? costPrice,
    int? stock,
    int? lowStockThreshold,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}