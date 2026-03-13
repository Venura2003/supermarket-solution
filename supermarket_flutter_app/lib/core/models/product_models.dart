// Product catalog models: Category, Attribute, Image, SKU, Variant, Product
import 'dart:convert';

class Category {
  final String id;
  final String name;
  final String? parentId;

  Category({required this.id, required this.name, this.parentId});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        parentId: json['parentId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parentId': parentId,
      };
}

class ProductAttribute {
  final String name;
  final String value;

  ProductAttribute({required this.name, required this.value});

  factory ProductAttribute.fromJson(Map<String, dynamic> json) => ProductAttribute(
        name: json['name'] as String,
        value: json['value'] as String,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };
}

class ProductImage {
  final String url;
  final String? alt;
  final int? sortOrder;

  ProductImage({required this.url, this.alt, this.sortOrder});

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
        url: json['url'] as String,
        alt: json['alt'] as String?,
        sortOrder: json['sortOrder'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'alt': alt,
        'sortOrder': sortOrder,
      };
}

class SKU {
  final String sku;
  final Map<String, String> attributes; // attributeName -> value
  final double price;
  final double costPrice; // Added
  final int stock;
  final String? barcode;

  SKU({required this.sku, required this.attributes, required this.price, this.costPrice = 0.0, required this.stock, this.barcode});

  factory SKU.fromJson(Map<String, dynamic> json) => SKU(
        sku: json['sku'] as String,
        attributes: Map<String, String>.from(json['attributes'] as Map? ?? {}),
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        barcode: json['barcode'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'attributes': attributes,
        'price': price,
        'costPrice': costPrice,
        'stock': stock,
        'barcode': barcode,
      };
}

class ProductVariant {
  final String id;
  final String name;
  final List<SKU> skus;

  ProductVariant({required this.id, required this.name, required this.skus});

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: json['id'] as String,
        name: json['name'] as String,
        skus: (json['skus'] as List?)?.map((e) => SKU.fromJson(Map<String, dynamic>.from(e as Map))).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'skus': skus.map((s) => s.toJson()).toList(),
      };
}

class Product {
  final String id;
  final String name;
  final String? description;
  final List<Category> categories;
  final List<ProductImage> images;
  final List<ProductAttribute> attributes;
  final List<SKU> skus; // flat list of SKUs
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.categories = const [],
    this.images = const [],
    this.attributes = const [],
    this.skus = const [],
    this.isActive = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        categories: (json['categories'] as List?)?.map((e) => Category.fromJson(Map<String, dynamic>.from(e as Map))).toList() ?? [],
        images: (json['images'] as List?)?.map((e) => ProductImage.fromJson(Map<String, dynamic>.from(e as Map))).toList() ?? [],
        attributes: (json['attributes'] as List?)?.map((e) => ProductAttribute.fromJson(Map<String, dynamic>.from(e as Map))).toList() ?? [],
        skus: (json['skus'] as List?)?.map((e) => SKU.fromJson(Map<String, dynamic>.from(e as Map))).toList() ?? [],
        isActive: json['isActive'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'categories': categories.map((c) => c.toJson()).toList(),
        'images': images.map((i) => i.toJson()).toList(),
        'attributes': attributes.map((a) => a.toJson()).toList(),
        'skus': skus.map((s) => s.toJson()).toList(),
        'isActive': isActive,
      };

    // SQLite-friendly map: nested lists are stored as JSON strings
    Map<String, dynamic> toMap() => {
      'id': id,
      'name': name,
      'description': description,
      'categories': jsonEncode(categories.map((c) => c.toJson()).toList()),
      'images': jsonEncode(images.map((i) => i.toJson()).toList()),
      'attributes': jsonEncode(attributes.map((a) => a.toJson()).toList()),
      'skus': jsonEncode(skus.map((s) => s.toJson()).toList()),
      'isActive': isActive ? 1 : 0,
      };

    factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      categories: (map['categories'] != null && (map['categories'] as String).isNotEmpty)
        ? (jsonDecode(map['categories'] as String) as List<dynamic>)
          .map((e) => Category.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        : [],
      images: (map['images'] != null && (map['images'] as String).isNotEmpty)
        ? (jsonDecode(map['images'] as String) as List<dynamic>)
          .map((e) => ProductImage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        : [],
      attributes: (map['attributes'] != null && (map['attributes'] as String).isNotEmpty)
        ? (jsonDecode(map['attributes'] as String) as List<dynamic>)
          .map((e) => ProductAttribute.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        : [],
      skus: (map['skus'] != null && (map['skus'] as String).isNotEmpty)
        ? (jsonDecode(map['skus'] as String) as List<dynamic>)
          .map((e) => SKU.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        : [],
      isActive: (map['isActive'] as int? ?? 1) == 1,
    );
    }
}
