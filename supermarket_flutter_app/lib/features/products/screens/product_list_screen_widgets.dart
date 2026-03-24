import 'package:flutter/material.dart';

// --- Summary Card Widget ---
class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Text('$value', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

// --- Filter Button Widget ---
class _FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterButton({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
          boxShadow: selected ? [BoxShadow(color: Colors.blue.withOpacity(0.15), blurRadius: 6)] : [],
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// --- Mobile Drawer Widget ---
class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Text('Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            _DrawerItem(icon: Icons.dashboard, label: 'Dashboard'),
            _DrawerItem(icon: Icons.inventory, label: 'Products'),
            _DrawerItem(icon: Icons.category, label: 'Categories'),
            _DrawerItem(icon: Icons.shopping_cart, label: 'Cart'),
            _DrawerItem(icon: Icons.people, label: 'Employees'),
            _DrawerItem(icon: Icons.bar_chart, label: 'Reports'),
            _DrawerItem(icon: Icons.settings, label: 'Settings'),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('FreshMart ERP', style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DrawerItem({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () => Navigator.of(context).pop(),
    );
  }
}