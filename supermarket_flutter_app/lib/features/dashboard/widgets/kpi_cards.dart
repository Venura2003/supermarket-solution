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
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
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
          ],
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
    final double updatedFont = widget.isMobile ? 10 : 12;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() {
        _hovering = false;
        _pressed = false;
      }),
      child: GestureDetector(
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
                    ? Colors.black.withOpacity(0.10)
                    : _hovering
                        ? Colors.black.withOpacity(0.13)
                        : Colors.black.withOpacity(0.07),
                blurRadius: _hovering ? 18 : 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: _hovering ? widget.color.withOpacity(0.18) : Colors.transparent,
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: widget.isMobile ? 10 : 12,
            horizontal: widget.isMobile ? 10 : 14,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color.withOpacity(0.95), widget.color.withOpacity(0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(widget.isMobile ? 8 : 12),
                child: Icon(widget.icon, size: iconSize, color: Colors.white),
              ),
              SizedBox(height: widget.isMobile ? 7 : 10),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: titleFont,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(height: widget.isMobile ? 4 : 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontSize: valueFont,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(height: widget.isMobile ? 2 : 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Updated just now',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                      fontSize: updatedFont,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}