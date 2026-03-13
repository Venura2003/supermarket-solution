class InventoryItem {
  final int id;
  final String sku;
  final String name;
  final int stock;
  final int reorderLevel;

  InventoryItem({required this.id, required this.sku, required this.name, required this.stock, required this.reorderLevel});

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'] ?? 0,
        sku: json['sku'] ?? json['code'] ?? '',
        name: json['name'] ?? json['title'] ?? '',
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        reorderLevel: (json['reorderLevel'] as num?)?.toInt() ?? 0,
      );
}
