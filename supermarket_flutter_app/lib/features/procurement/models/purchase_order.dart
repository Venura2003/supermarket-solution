import 'purchase_order_item.dart';

class PurchaseOrder {
  final int id;
  final int supplierId;
  final String supplierName;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final String status;
  final double totalAmount;
  final List<PurchaseOrderItem> items;

  PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.orderDate,
    this.expectedDeliveryDate,
    required this.status,
    required this.totalAmount,
    required this.items,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] ?? 0,
      supplierId: json['supplierId'] ?? 0,
      supplierName: json['supplierName'] ?? 'Unknown Supplier', // If backend flattens it
      orderDate: DateTime.parse(json['orderDate']),
      expectedDeliveryDate: json['expectedDeliveryDate'] != null ? DateTime.parse(json['expectedDeliveryDate']) : null,
      status: json['status'] ?? 'Pending',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => PurchaseOrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'orderDate': orderDate.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'status': status,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
