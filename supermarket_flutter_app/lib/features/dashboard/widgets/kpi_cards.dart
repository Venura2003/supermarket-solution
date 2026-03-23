import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';

class KpiCards extends StatelessWidget {
  const KpiCards({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final theme = Theme.of(context);

    // Debug print for KPI values
    debugPrint('[KPI] totalRevenue: 	{dashboardProvider.totalRevenue}, monthlyRevenue: 	{dashboardProvider.monthlyRevenue}, totalOrders: 	{dashboardProvider.totalOrders}, lowStockCount: 	{dashboardProvider.lowStockCount}');
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      final cardWidth = isMobile ? constraints.maxWidth : 260.0;
      final horizontalPadding = isMobile ? 0.0 : 8.0;
      final kpiCards = [
        _KpiCard(
          title: 'Total Sales Today',
          value: dashboardProvider.totalRevenue > 0
              ? 'LKR ${NumberFormat('#,##0.00').format(dashboardProvider.totalRevenue)}'
              : 'No data',
          icon: Icons.attach_money,
          color: Colors.green.shade700,
          isMobile: isMobile,
          width: cardWidth,
        ),
        _KpiCard(
          title: 'Monthly Revenue',
          value: dashboardProvider.monthlyRevenue > 0
              ? 'LKR ${NumberFormat('#,##0.00').format(dashboardProvider.monthlyRevenue)}'
              : 'No data',
          icon: Icons.calendar_month,
          color: Colors.blue.shade700,
          isMobile: isMobile,
          width: cardWidth,
        ),
        _KpiCard(
          title: 'Total Orders',
          value: dashboardProvider.totalOrders > 0
              ? dashboardProvider.totalOrders.toString()
              : 'No data',
          icon: Icons.shopping_cart,
          color: Colors.orange.shade700,
          isMobile: isMobile,
          width: cardWidth,
        ),
        _KpiCard(
          title: 'Low Stock Items',
          value: dashboardProvider.lowStockCount >= 0
              ? dashboardProvider.lowStockCount.toString()
              : 'No data',
          icon: Icons.warning,
          color: Colors.red.shade700,
          isMobile: isMobile,
          width: cardWidth,
        ),
      ];
      // More visible animation: slide from below, fade in, scale in
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Wrap(
          spacing: 24, // more space between cards
          runSpacing: 24,
          children: List.generate(kpiCards.length, (i) =>
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 900 + i * 200),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 60 * (1 - value)),
                  child: Transform.scale(
                    scale: 0.85 + 0.15 * value,
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  ),
                );
              },
              child: kpiCards[i],
            ),
          ),
        ),
      );
    });
  }
}

class _KpiCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isMobile;
  final double? width;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isMobile = false,
    this.width,
  });

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double iconSize = widget.isMobile ? 22 : 28;
    final double titleFont = widget.isMobile ? 13 : 15;
    final double valueFont = widget.isMobile ? 16 : 20;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() {
        _hovering = false;
        _pressed = false;
      }),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: widget.color.withOpacity(0.18),
          highlightColor: widget.color.withOpacity(0.10),
          onTap: () {}, // Demo ripple
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: widget.width,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _pressed
                      ? Colors.black.withOpacity(0.13)
                      : _hovering
                          ? widget.color.withOpacity(0.22)
                          : Colors.black.withOpacity(0.09),
                  blurRadius: _hovering ? 22 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: _hovering ? widget.color.withOpacity(0.28) : Colors.transparent,
                width: 2.0,
              ),
            ),
            padding: EdgeInsets.symmetric(
              vertical: widget.isMobile ? 12 : 16,
              horizontal: widget.isMobile ? 12 : 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.color.withOpacity(1.0), widget.color.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.25),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(iconSize * 0.6),
                  child: Icon(widget.icon, color: Colors.white, size: iconSize),
                ),
                SizedBox(height: widget.isMobile ? 10 : 16),
                Text(
                  widget.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: titleFont,
                    color: theme.colorScheme.onSurface.withOpacity(0.85),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Text(
                  widget.value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: valueFont,
                    color: widget.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
