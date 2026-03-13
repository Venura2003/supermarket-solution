import 'package:intl/intl.dart';

class OrderItem {
  final int id;
  final int productId;
  final String name;
  final int quantity;
  final int refundedQuantity;
  final double unitPrice;
  final double discount;
  final double lineTotal;

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    this.refundedQuantity = 0,
    required this.unitPrice,
    this.discount = 0.0,
    required this.lineTotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'] ?? 0,
        productId: json['productId'] ?? 0,
        name: json['productName'] ?? json['name'] ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        refundedQuantity: (json['refundedQuantity'] as num?)?.toInt() ?? 0,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
        discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
        lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
      );

  double get total => lineTotal;
}

class Order {
  final int id;
  final String code;
  final String status;
  final double totalAmount;
  final double discountAmount;
  final String paymentMethod;
  final String? customerName;
  final List<OrderItem> items;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.code,
    required this.status,
    required this.totalAmount,
    this.discountAmount = 0.0,
    required this.paymentMethod,
    this.customerName,
    required this.items,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List<dynamic>?) ?? <dynamic>[];
    return Order(
      id: json['id'] ?? 0,
      code: json['orderNo'] ?? json['code'] ?? '',
      status: json['status'] ?? 'Pending',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'Cash',
      customerName: json['employeeName'], // API returns 'employeeName'
      items: itemsJson.map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: DateTime.tryParse(json['orderDate']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  double get total => totalAmount;

  String get formattedDate => DateFormat('yyyy-MM-dd HH:mm').format(createdAt);
}
