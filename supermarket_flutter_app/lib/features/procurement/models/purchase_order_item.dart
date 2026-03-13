class PurchaseOrderItem {
  final int id;
  final int purchaseOrderId;
  final int productId;
  final String productName; // Assuming backend includes this or we fetch it
  final int quantity;
  final double unitCost;
  final double totalCost;

  PurchaseOrderItem({
    required this.id,
    required this.purchaseOrderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      id: json['id'] ?? 0,
      purchaseOrderId: json['purchaseOrderId'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? 'Unknown Product',
      quantity: json['quantity'] ?? 0,
      unitCost: (json['unitCost'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchaseOrderId': purchaseOrderId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitCost': unitCost,
      'totalCost': totalCost,
    };
  }
}
