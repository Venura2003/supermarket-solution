class DailySalesReport {
  final DateTime date;
  final double totalSalesAmount;
  final int totalOrders;

  DailySalesReport({
    required this.date,
    required this.totalSalesAmount,
    required this.totalOrders,
  });

  factory DailySalesReport.fromJson(Map<String, dynamic> json) {
    return DailySalesReport(
      date: DateTime.parse(json['date']),
      totalSalesAmount: (json['totalSalesAmount'] as num).toDouble(),
      totalOrders: json['totalOrders'],
    );
  }
}

class MonthlySalesReport {
  final int year;
  final int month;
  final double totalSalesAmount;
  final int totalOrders;

  MonthlySalesReport({
    required this.year,
    required this.month,
    required this.totalSalesAmount,
    required this.totalOrders,
  });

  factory MonthlySalesReport.fromJson(Map<String, dynamic> json) {
    return MonthlySalesReport(
      year: json['year'],
      month: json['month'],
      totalSalesAmount: (json['totalSalesAmount'] as num).toDouble(),
      totalOrders: json['totalOrders'],
    );
  }
}

class TopProduct {
  final int productId;
  final String name;
  final int quantitySold;
  final double revenue;

  TopProduct({required this.productId, required this.name, required this.quantitySold, required this.revenue});

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['productId'] ?? json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? 'Unknown',
      quantitySold: json['quantitySold'] ?? json['qty'] ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}