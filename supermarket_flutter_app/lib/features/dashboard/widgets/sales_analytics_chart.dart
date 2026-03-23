import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';

class SalesAnalyticsChart extends StatelessWidget {
  final double? dailySalesOverride;
  final double? monthlySalesOverride;
  final bool isLoadingOverride;
  final String dailyLabel;
  final String monthlyLabel;

  const SalesAnalyticsChart({
    super.key,
    this.dailySalesOverride,
    this.monthlySalesOverride,
    this.isLoadingOverride = false,
    this.dailyLabel = 'Today',
    this.monthlyLabel = 'This Month',
  });

  @override
  Widget build(BuildContext context) {
    double dailyRevenue = 0.0;
    double monthlyRevenue = 0.0;
    bool isLoading = isLoadingOverride;

    if (dailySalesOverride != null || monthlySalesOverride != null) {
      dailyRevenue = dailySalesOverride ?? 0.0;
      monthlyRevenue = monthlySalesOverride ?? 0.0;
    } else {
      final dashboardProvider = Provider.of<DashboardProvider>(context);
      isLoading = dashboardProvider.isLoading;
      dailyRevenue = dashboardProvider.dailyReport?.totalSalesAmount ?? 0.0;
      monthlyRevenue = dashboardProvider.monthlyReport?.totalSalesAmount ?? 0.0;
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    return AnimatedSlide(
      offset: const Offset(0, 0.15),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 500),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.primary.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Sales Analytics',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY:
                        [
                          dailyRevenue,
                          monthlyRevenue,
                        ].reduce((a, b) => a > b ? a : b) *
                        1.2,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    dailyLabel,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              case 1:
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    monthlyLabel,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              default:
                                return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              'LKR ${NumberFormat.compact().format(value)}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontSize: 13,
                                color: theme.colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: dailyRevenue,
                            color: theme.colorScheme.primary,
                            width: 36,
                            borderRadius: BorderRadius.circular(10),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY:
                                  [
                                    dailyRevenue,
                                    monthlyRevenue,
                                  ].reduce((a, b) => a > b ? a : b) *
                                  1.2,
                              color: theme.colorScheme.primary.withOpacity(
                                0.10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: monthlyRevenue,
                            color: Colors.green.shade600,
                            width: 32,
                            borderRadius: BorderRadius.circular(8),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY:
                                  [
                                    dailyRevenue,
                                    monthlyRevenue,
                                  ].reduce((a, b) => a > b ? a : b) *
                                  1.2,
                              color: Colors.green.withOpacity(0.08),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _LegendItem(
                    color: theme.colorScheme.primary,
                    label: dailyLabel,
                  ),
                  const SizedBox(width: 18),
                  _LegendItem(color: Colors.green, label: monthlyLabel),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Top-level _LegendItem widget for chart legends
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
