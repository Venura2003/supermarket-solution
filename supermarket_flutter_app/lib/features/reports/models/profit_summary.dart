class ProfitSummary {
  final double totalSales;
  final double totalProductCost;
  final double grossProfit;
  final double totalExpenses;
  final double netProfit;
  final String period; // "Monthly", "Yearly" etc.

  ProfitSummary({
    required this.totalSales,
    required this.totalProductCost,
    required this.grossProfit,
    required this.totalExpenses,
    required this.netProfit,
    this.period = 'Overall',
  });

  factory ProfitSummary.fromJson(Map<String, dynamic> json) {
    return ProfitSummary(
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      totalProductCost: (json['totalCost'] ?? 0).toDouble(), // Backend DTO might be TotalCost
      grossProfit: (json['grossProfit'] ?? 0).toDouble(),
      totalExpenses: (json['totalExpenses'] ?? 0).toDouble(),
      netProfit: (json['netProfit'] ?? 0).toDouble(),
      period: json['period'] ?? 'Overall',
    );
  }
}
